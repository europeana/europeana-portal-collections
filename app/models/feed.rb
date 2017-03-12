# frozen_string_literal: true
class Feed < ActiveRecord::Base
  include HasExternalUrls
  include IsPermissionable

  has_and_belongs_to_many :pages

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true

  before_create :set_editor_permissions
  after_save :queue_retrieval

  acts_as_url :name, url_attribute: :slug, only_when_blank: true, allow_duplicates: false

  def html_url
    if tumblr?
      url.sub('/rss', '')
    elsif europeana_blog?
      url.sub('/feed', '')
    else
      url
    end
  end

  def to_param
    slug
  end

  private

  def queue_retrieval
    Cache::FeedJob.perform_later(url, true)
  end
end
