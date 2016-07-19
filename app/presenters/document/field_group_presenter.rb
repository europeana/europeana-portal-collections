# frozen_string_literal: true
module Document
  ##
  # Presenter for a group of document fields
  class FieldGroupPresenter < DocumentPresenter
    include Field::Entities

    def display(id)
      definition = Document::Field::Groups.send(id)

      sections = definition[:sections].map do |section|
        {
          title: section[:title].nil? ? false : t(section[:title], scope: 'site.object.meta-label'),
          items: section_field_subsection(section)
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
      return text if format.nil? || (text ! =~ /^.+-/)
      Time.parse(text).strftime(format)
    rescue ArgumentError
      text
    end

    def section_field_values(section)
      if section[:entity_name] && section[:entity_proxy_field]
        fields = entity_fields(section[:entity_name], section[:entity_proxy_field])
      elsif section[:fields]
        fields = [section[:fields]].flatten.map do |field|
          document.fetch(field, [])
        end
      else
        fields = []
      end

      fields = fields.flatten.compact.uniq

      if section[:exclude_vals].present?
        fields -= section[:exclude_vals]
      end

      return fields if section[:fields_then_fallback] && fields.present?

      collected = section[:collected].present? ? section[:collected].call(document) : nil
      fields = ([collected] + fields).flatten.compact.uniq
      return fields if section[:entity_name] && section[:entity_proxy_field]

      entity_uris = document.fetch('agents.about', []) || []
      fields.reject { |field| entity_uris.include?(field) }
    end

    def section_field_search_path(val, field, quoted)
      return unless val.is_a?(String)

      search_val = val.gsub(/[()\[\]<>]/, '')

      format = quoted ? '"%s"' : '(%s)'
      search_val = sprintf(format, search_val)

      routes.search_path(controller.default_url_options.merge(q: "#{field}:#{search_val}"))
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

          # overrides
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
          val = render_document_show_field_value(subject, mapping[:field])
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
