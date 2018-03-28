# frozen_string_literal: true

class Banner < ActiveRecord::Base
  include HasPublicationStates

  has_one :link, as: :linkable, dependent: :destroy
  has_many :pages, dependent: :nullify, inverse_of: :banner

  accepts_nested_attributes_for :link

  delegate :url, :text, to: :link, prefix: true, allow_nil: true

  before_save(if: :became_default?) do
    Banner.update_all(default: false)
  end

  has_paper_trail

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  after_update :touch_pages
  after_touch :touch_pages
  after_destroy :touch_pages

  ##
  # Touch associated pages to invalidate cache
  def touch_pages
    if default?
      Page.where('banner_id IS NULL').find_each(&:touch)
    end
    pages.find_each(&:touch)
  end

  def became_default?
    default? && default_changed?
  end
end
