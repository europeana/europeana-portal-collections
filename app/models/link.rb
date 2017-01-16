class Link < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true, touch: true

  validates :url, presence: true
  validates :url, url: { allow_local: true }, allow_nil: true

  has_paper_trail

  translates :text, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  def url_in_domain?(domain)
    !(url =~ %r(://([^/]*.)?#{domain}/)).nil?
  end
end
