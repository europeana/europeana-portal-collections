# frozen_string_literal: true

module NamedEntityDisplayingView
  extend ActiveSupport::Concern

  def named_entity_labels(edm, i18n, *args)
    fields = named_entity_fields(edm, i18n, *args)
    return nil if fields.empty?
    {
      title: t("site.object.named-entities.#{i18n}.title"),
      fields: fields
    }
  end

  def named_entity_fields(edm, i18n, *args)
    properties = %i(about prefLabel) + (args || [])
    document.fetch(edm, []).map do |entity|
      properties.map do |f|
        named_entity_field_content(entity, f, i18n)
      end
    end.flatten.compact
  end

  def named_entity_field_content(entity, field, i18n)
    val = normalise_named_entity(entity[field.to_sym])

    if val.present?
      val = val.first if val.is_a?(Array) && val.size == 1
      multi = (val.is_a?(Hash) || val.is_a?(Array)) && (val.size > 1)
      {
        key: t(named_entity_field_label_i18n_key(field), scope: "site.object.named-entities.#{i18n}"),
        val: multi ? nil : val,
        vals: multi ? val : nil,
        multi: multi,
        foldable_link: linkable_named_entity_value?(field, val)
      }
    end
  end

  def named_entity_field_label_i18n_key(field)
    map = { about: 'term', prefLabel: 'label' }
    map.key?(field) ? map[field] : field
  end

  def linkable_named_entity_value?(field, val)
    return false unless named_entity_link_field?(field)
    return false unless val.is_a?(String)
    !!(val =~ /\A#{URI.regexp(%w(http https))}\z/)
  end

  def named_entity_link_field?(field)
    %i(about broader).include?(field)
  end

  def normalise_named_entity(named_entity)
    return [] if named_entity.nil?
    return named_entity unless named_entity.is_a?(Hash)

    if named_entity.key?(:def) && named_entity.size == 1 && named_entity[:def].size == 1
      return named_entity[:def]
    end

    named_entity.map do |key, val|
      if key && val.nil?
        # TODO: What is the use case for this?
        { val: key, key: nil }
      else
        { key: key, val: val }
      end
    end
  end
end
