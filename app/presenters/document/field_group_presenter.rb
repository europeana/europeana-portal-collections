# frozen_string_literal: true

module Document
  ##
  # Presenter for a group of document fields
  class FieldGroupPresenter < DocumentPresenter
    include Field::Entities
    include Field::Labelling
    include EntitiesHelper
    include UrlHelper

    ##
    # Load the field group definition from the config file
    def self.definition(id)
      @definitions ||= load_definitions
      @definitions[id]
    end

    def self.load_definitions
      file_path = File.join(Rails.root, 'config', 'record_field_groups.yml')
      YAML.load_file(file_path).with_indifferent_access.freeze
    end

    def initialize(*args)
      super
      @entity_fallbacks_used = []
    end

    def display(id)
      definition = self.class.definition(id)

      sections = definition[:sections].map do |section|
        {
          title: section[:title].nil? ? false : t(section[:title], scope: 'site.object.meta-label'),
          items: section_field_subsection(section),
          is_desc: id.to_s == 'description'
        }
      end

      sections.reject! { |section| section[:items].blank? || section[:items][0][:text].blank? }

      sections.blank? ? nil : {
        title: t(definition[:title], scope: 'site.object.meta-label'),
        sections: sections
      }
    end

    protected

    def format_date(text, format)
      return text if format.nil? || !(text =~ /^.+-/)
      Time.parse(text).strftime(format)
    rescue ArgumentError
      text
    end

    def map_field_values(values, map)
      values.map do |val|
        if map.key?(val)
          map[val] ? I18n.t(map[val]) : nil
        else
          val
        end
      end
    end

    def section_field_values(section)
      fields = if entity_section?(section)
                 entity_fields(section[:entity_name], section[:entity_proxy_field])
               elsif section[:fields]
                 [section[:fields]].flatten.map do |field|
                   field.ends_with?('.prefLabel') ? pref_label(document, field) : document.fetch(field, [])
                 end
               else
                 []
               end

      fields = fields.flatten.compact.uniq

      fields -= section[:exclude_vals] if section[:exclude_vals].present?

      fields = map_field_values(fields, section[:map_values]) if section[:map_values]

      if section[:entity_fallback]
        return fields if fields.present?
        fields = section_field_values(fields: section[:entity_fallback])
        @entity_fallbacks_used << entity_section_memo_key(section)
      end

      return fields if entity_section?(section)

      entity_uris = document.fetch('agents.about', []) || []
      fields.reject { |field| entity_uris.include?(field) }
    end

    def section_field_search_path(val, field, quoted)
      return unless val.is_a?(String)

      search_val = val.gsub(/[()\[\]<>]/, '')

      search_val = quoted ? enquote_and_escape(search_val) : parenthesise_and_escape(search_val)

      search_path(controller.default_url_options.merge(q: "#{field}:#{search_val}"))
    end

    def section_field_subsection(section)
      field_values = section_field_values(section).compact
      field_values = field_values.slice(0, section[:max]) if section[:max].present?
      field_values.map do |val|
        section_field_subsection_item(section, val)
      end
    end

    def section_field_subsection_item(section, val)
      {
        text: section_field_subsection_item_text(section, val),
        url: section_field_subsection_item_url(section, val),
        ga_data: section[:ga_data],
        extra_info: section_field_subsection_item_extra_info(section, val)
      }
    end

    def section_field_subsection_item_extra_info(section, val)
      return nil unless entity_section?(section) && section[:entity_extra].present?
      entity = entity_for(section, val)
      return nil unless entity.present?
      section_nested_hash(section[:entity_extra], entity)
    end

    def section_field_subsection_item_url(section, val)
      if section[:url]
        return field_value(section[:url])
      end

      if linkable_entity_section?(section)
        entity_url = entity_url_for(section, val)
        return entity_url unless entity_url.nil?
      end

      if section[:search_field]
        return section_field_search_path(val, section[:search_field], section[:quoted])
      end

      linkable_value?(val) ? val : nil
    end

    def entity_url_for(section, val)
      entity = entity_for(section, val)
      return nil unless entity.present?

      entity_uri = URI.parse(entity.fetch('about'))
      return nil unless entity_uri.host == 'data.europeana.eu'

      type, _namespace, id = entity_uri.path.split('/').slice(1..-1)

      entity_path(type: entities_human_type(type), id: id, slug: entity_url_slug(entity), format: 'html')
    end

    def entity_for(section, val)
      return nil unless entity_section?(section)

      memo_key = entity_section_memo_key(section)

      @section_entities ||= {}
      @section_entities[memo_key] ||= entities(section[:entity_name], section[:entity_proxy_field])

      @field_entities ||= {}
      @field_entities[memo_key] ||= {}
      @field_entities[memo_key][val] ||= begin
        @section_entities[memo_key].detect do |entity|
          [entity_label(entity, section[:entity_name])].flatten.any? { |label| label == val }
        end
      end
    end

    def entity_section_memo_key(section)
      [section[:entity_name], section[:entity_proxy_field]].join('/')
    end

    def section_field_subsection_item_text(section, val)
      text = val
      text = text.titleize if text.present? && section[:capitalised]
      text = format_date(text, section[:format_date]) if section[:format_date]
      text
    end

    def linkable_value?(value)
      return false unless value.is_a?(String)
      value.start_with?('http://', 'https://')
    end

    ##
    # Creates a nested hash of field values for Mustache template
    def section_nested_hash(mappings, subject = document)
      {}.tap do |hash|
        mappings.each do |mapping|
          val = subject.fetch(mapping[:field], nil)
          val = render_field_value(val)
          next unless val.present?

          keys = (mapping[:map_to] || mapping[:field]).split('.')
          last = keys.pop

          context = hash
          keys.each do |k|
            context[k] ||= {}
            context = context[k]
          end
          context[last] = format_date(val, mapping[:format_date])
        end
      end
    end

    private

    def entity_section?(section)
      section[:entity_name] && section[:entity_proxy_field]
    end

    def linkable_entity_section?(section)
      Rails.application.config.x.enable.entity_page &&
        entity_section?(section) &&
        !@entity_fallbacks_used.include?(entity_section_memo_key(section)) &&
        section[:entity_name] == 'agents' # while only agent entity pages are implemented
    end
  end
end
