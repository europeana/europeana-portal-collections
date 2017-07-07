# frozen_string_literal: true

class BrowseEntry < ActiveRecord::Base
  include HasPublicationStates
  include IsPageElementPositionable
  include IsPermissionable

  has_and_belongs_to_many :collections
  belongs_to :media_object, dependent: :destroy

  delegate :file, to: :media_object, allow_nil: true

  accepts_nested_attributes_for :media_object, allow_destroy: true

  validates :subject_type, presence: true, unless: :facet?

  scope :search, -> { where(type: nil) }

  # Do not re-order these elements!
  # @see http://api.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum subject_type: [:topic, :person, :period]

  translates :title, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  def facet?
    false
  end

  def file=(*args)
    (media_object || build_media_object).send(:file=, *args)
  end
end
