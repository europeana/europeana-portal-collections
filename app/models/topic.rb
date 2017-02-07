# frozen_string_literal: true
class Topic < ActiveRecord::Base
  translates :name, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
end
