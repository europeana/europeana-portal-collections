class Banner < ActiveRecord::Base
  include HasPublicationStates

  has_one :link, as: :linkable, dependent: :destroy

  accepts_nested_attributes_for :link

  delegate :url, :text, to: :link, prefix: true

  validates :key, uniqueness: true, allow_nil: true

  has_paper_trail

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  after_update :touch_pages, if: :phase_feedback_banner?
  after_touch :touch_pages, if: :phase_feedback_banner?

  ##
  # All published pages display the phase feedback banner; touch them to
  #   invalidate cache
  def touch_pages
    Page.published.find_each do |p|
      p.touch
    end
  end

  ##
  # @todo this is inelegant, does not belong in the model; devise a proper
  #   banner to page association
  def phase_feedback_banner?
    key == 'phase-feedback'
  end
end
