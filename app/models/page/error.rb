class Page::Error < Page
  HTTP_ERROR_STATUS_CODES = Rack::Utils::HTTP_STATUS_CODES.keys.select { |code| (400..599).include?(code) }

  validates :http_code, presence: true, uniqueness: true,
                        inclusion: { in: HTTP_ERROR_STATUS_CODES }

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  before_validation do |page|
    unless page.http_code.nil? || Rack::Utils::HTTP_STATUS_CODES[page.http_code].nil?
      page.slug = 'errors/' + Rack::Utils::HTTP_STATUS_CODES[page.http_code].downcase.gsub(' ', '_')
    end
  end
end
