class Page::Landing < Page
  has_many :credits, -> { order(:position) }, as: :linkable, class_name: 'Link::Credit', dependent: :destroy
  has_many :social_media, -> { order(:position) }, as: :linkable, class_name: 'Link::SocialMedia', dependent: :destroy
  has_many :promotions, -> { order(:position) }, as: :linkable, class_name: 'Link::Promotion', dependent: :destroy

  accepts_nested_attributes_for :credits, allow_destroy: true
  accepts_nested_attributes_for :social_media, allow_destroy: true
  accepts_nested_attributes_for :promotions, allow_destroy: true

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
end
