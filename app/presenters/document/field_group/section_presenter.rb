# frozen_string_literal: true

module Document
  ##
  # Presenter for a record metadata "section", which may gather data from multiple
  # source fields
  module FieldGroup
    class SectionPresenter < DocumentPresenter
      include Document::Field::Entities

      attr_reader :definition, :group

      delegate :search_field, :entity, :fields, :exclude_vals, :max, :title,
               :ga_data, :map_values, :format_date, to: :definition

      # @param document [Europeana::Blacklight::Document]
      # @param controller [ActionController::Base]
      # @param group [Document::FieldGroupPresenter]
      # @param definition [OpenStruct]
      def initialize(document, controller, group, definition)
        unless definition.fields.present?
          fail ArgumentError, "Field group definition requires fields, none present: #{definition.inspect}"
        end

        super(document, controller)
        @group = group
        @definition = definition
      end

      def display
        {
          title: display_title,
          items: display_items,
          is_desc: group.for_description?
        }
      end

      def display_title
        title.nil? ? false : t(title, scope: 'site.object.meta-label')
      end

      def display_items
        value_presenters.map(&:display)
      end

      def value_presenters
        prune_value_presenters!(all_value_presenters)
      end

      def all_value_presenters
        [fields].flatten.map { |field| value_presenters_for_field(field) }.flatten
      end

      def prune_value_presenters!(presenters)
        presenters.reject!(&:blank?)
        reject_entity_label_duplicating_value_presenters!(presenters)
        presenters.uniq!(&:text)
        presenters.reject!(&:excluded?)
        reject_agent_uri_value_presenters!(presenters)
        enforce_max_value_presenters!(presenters)
        presenters
      end

      # Where multiple values have same text, favour those for entities,
      # e.g. "Art" dc:type on /portal/record/08533/artifact_aspx_id_1063.html
      # Also omit any other labels of known entities, e.g. altLabel "Bowie, David"
      # dc:creator on /portal/record/2059218/data_sounds_IT_DDS0000072541000000.html
      def reject_entity_label_duplicating_value_presenters!(presenters)
        presenters.reject! do |value|
          !value.for_entity? && presenters.detect do |other_value|
            value != other_value &&
              other_value.for_entity? &&
              entity_potential_labels(other_value.entity).include?(value.text)
          end
        end
      end

      # TODO: confirm if this is still useful
      def reject_agent_uri_value_presenters!(presenters)
        entity_uris = document.fetch('agents.about', []) || []
        presenters.reject! { |v| entity_uris.include?(v.text) }
      end

      def enforce_max_value_presenters!(presenters)
        presenters = presenters.slice(0, max) if max.present?
        presenters
      end

      def document_field_contents(field)
        field_contents = [document.fetch(field, [])].flatten
        field_contents = [field_contents.first] if field.ends_with?('.prefLabel')
        field_contents
      end

      def value_presenters_for_field(field)
        presenters = for_entity? ? value_presenters_for_entity_field(field) : []
        presenters.compact!
        if presenters.blank? && (!for_entity? || entity_fallback?)
          presenters = document_field_contents(field).map do |content|
            value_presenter(field, content)
          end
        end
        presenters
      end

      def value_presenters_for_entity_field(field)
        field_entities = document_entities(entity_name, field)
        field_contents = document_field_contents(field)

        field_contents.map do |content|
          field_entity = field_entities.detect { |fe| fe[:about] == content }

          if field_entity.present?
            [entity_label(field_entity)].flatten.map do |label|
              value_presenter(field, label, field_entity)
            end
          elsif entity_fallback?
            value_presenter(field, content)
          end
        end
      end

      def value_presenter(field, content, entity = nil)
        Document::FieldGroup::Section::ValuePresenter.new(document, controller, self, field, content, entity)
      end

      def entity_about
        entity[:about]
      end

      def entity_extra
        entity[:extra]
      end

      def entity_name
        entity[:name]
      end

      def entity_fallback?
        entity.key?(:fallback) && entity[:fallback]
      end

      def quoted?
        definition.quoted.present?
      end

      def capitalised?
        definition.capitalised.present?
      end

      def exclude_vals?
        exclude_vals.present?
      end

      def format_date?
        format_date.present?
      end

      def translate_values?
        map_values.present?
      end

      def translate_value?(val)
        translate_values? && map_values.key?(val)
      end

      def translate_value(val)
        translate_value?(val) ? I18n.t(map_values[val]) : val
      end

      def for_entity?
        entity.present?
      end
    end
  end
end
