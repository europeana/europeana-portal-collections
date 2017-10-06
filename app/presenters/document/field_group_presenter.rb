# frozen_string_literal: true

module Document
  ##
  # Presenter for a group of document fields
  class FieldGroupPresenter < ApplicationPresenter
    attr_reader :document, :controller, :id, :definition, :sections

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

    # @param document [Europeana::Blacklight::Document]
    # @param controller [ActionController::Base]
    # @param id [String,Symbol]
    def initialize(document, controller, id)
      @document = document
      @controller = controller
      @id = id
      @definition = self.class.definition(id)
      @sections = @definition[:sections].map do |section_definition|
        Document::FieldGroup::SectionPresenter.new(document, controller, self, OpenStruct.new(section_definition).freeze)
      end
    end

    def display
      return nil if display_sections.blank?

      {
        title: display_title,
        sections: display_sections
      }
    end

    def for_description?
      id.to_s == 'description'
    end

    protected

    def display_title
      t(definition[:title], scope: 'site.object.meta-label')
    end

    def display_sections
      @display_sections ||= sections.map(&:display).reject { |section| section[:items].blank? }
    end
  end
end
