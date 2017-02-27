# frozen_string_literal: true
class Feed < ActiveRecord::Base
  include HasExternalUrls

  has_and_belongs_to_many :pages

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true

  acts_as_url :name, url_attribute: :slug, only_when_blank: true, allow_duplicates: false

  scope :tumblr, -> { where('url LIKE (?)', '%tumblr.com%') }

  def to_param
    slug
  end
end
