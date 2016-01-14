class Page::Error < Page
  HTTP_ERROR_STATUS_CODES = Rack::Utils::HTTP_STATUS_CODES.keys.select { |code| (400..599).include?(code) }

  validates :http_code, presence: true, inclusion: { in: HTTP_ERROR_STATUS_CODES }
  validates :http_code, uniqueness: true, unless: :exception?

  validates :slug, format: { with: /\A(errors|exceptions)\/.+\z/ }

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  scope :exception, -> { where("slug LIKE 'exceptions/%'") }
  scope :generic, -> { where("slug LIKE 'errors/%'") }

  def self.for_exception(exception, http_code)
    find_by slug: "exceptions/#{exception.class.to_s.underscore}",
            http_code: http_code
  end

  def exception?
    slug.match(/\Aexceptions\//).present?
  end
end
