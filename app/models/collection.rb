class Collection < ActiveRecord::Base
  include HasPublicationStates

  has_and_belongs_to_many :browse_entries

  has_paper_trail

  validates :key, presence: true, uniqueness: true
  validates :api_params, presence: true

  after_save :touch_landing_page

  def to_param
    key
  end

  def api_params_hash
    {}.tap do |hash|
      api_params.split('&').map do |param|
        key, val = param.split('=')
        hash[key] ||= []
        hash[key] << val
      end
    end
  end

  def landing_page
    @landing_page ||= Page::Landing.find_by_slug(landing_page_slug)
  end

  def landing_page_slug
    "collections/#{key}"
  end

  def touch_landing_page
    landing_page.touch if landing_page.present?
  end
end
