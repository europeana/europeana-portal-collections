# frozen_string_literal: true
class Topic < ActiveRecord::Base
  has_many :categorisations, inverse_of: :topic, dependent: :destroy

  validates :label, presence: true, uniqueness: true
  validates :entity_uri, uniqueness: true, allow_blank: true

  translates :label, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  acts_as_url :label, url_attribute: :slug, only_when_blank: true,
                      allow_duplicates: false

  default_scope { includes(:translations).order('topic_translations.label') }

  def to_param
    slug
  end
end
