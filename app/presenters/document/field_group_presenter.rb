# frozen_string_literal: true
module Document
  ##
  # Presenter for a group of document fields
  class FieldGroupPresenter < DocumentPresenter
    include Field::Entities
    include Field::Labelling

    ##
    # Load the field group definition from the config file
    def self.definition(id)
      @definitions ||= load_definitions
      @definitions[id]
    end

    def self.load_definitions
      YAML::load_file(File.join(Rails.root, 'config', 'record_field_groups.yml')).with_indifferent_access
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
        map.key?(val) ? I18n.t(map[val]) : val
      end
    end

    def section_field_values(section)
      fields = if section[:entity_name] && section[:entity_proxy_field]
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
      end

      return fields if section[:entity_name] && section[:entity_proxy_field]

      entity_uris = document.fetch('agents.about', []) || []
      fields.reject { |field| entity_uris.include?(field) }
    end

    def section_field_search_path(val, field, quoted)
      return unless val.is_a?(String)

      search_val = val.gsub(/[()\[\]<>]/, '')

      format = quoted ? '"%s"' : '(%s)'
      search_val = sprintf(format, search_val)

      search_path(controller.default_url_options.merge(q: "#{field}:#{search_val}"))
    end

    def section_field_subsection(section)
      field_values = section_field_values(section)

      field_values.compact.map do |val|
        {}.tap do |item|
          item[:text] = val
          if section[:url]
            item[:url] = render_document_show_field_value(document, section[:url])
          elsif section[:search_field]
            item[:url] = section_field_search_path(val, section[:search_field], section[:quoted])
          end

          # text manipulation
          item[:text] = format_date(val, section[:format_date])

#          puts item.as_json.to_s

          if section[:overrides] && item[:text] == section[:override_val]
            section[:overrides].map do |override|
              if override[:field_title]
                item[:text] = override[:field_title]
              end
              if override[:field_url]
                item[:url] = override[:field_url]
              end
            end
          end

          if val.start_with?('http')
            item[:url] = val
          end

          if section[:ga_data]
            item[:ga_data] = section[:ga_data]
          end

          # extra entity info
          if section[:entity_extra].present?
            possible_entities = entities(section[:entity_name], section[:entity_proxy_field])
            salient_entity = possible_entities.detect do |entity|
              entity_label(entity).any? { |label| label == val }
            end
            unless salient_entity.nil?
              item[:extra_info] = section_nested_hash(section[:entity_extra], salient_entity)
            end
          end
        end
      end
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
  end
end
