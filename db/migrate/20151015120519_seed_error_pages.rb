class SeedErrorPages < ActiveRecord::Migration
  PAGES = [
    { title: 'Internal Server Error', body: 'Something went wrong.', http_code: 500 },
    { title: 'Forbidden', body: 'You do not have permission to access this resource.', http_code: 403 }
  ]

  def up
    PAGES.each do |attrs|
      page = Page::Error.find_or_initialize_by(http_code: attrs[:http_code])
      page.attributes = attrs
      page.save
      page.publish!
    end
  end

  def down
    PAGES.each do |attrs|
      page = Page::Error.find_or_initialize_by(http_code: attrs[:http_code])
      page.destroy unless page.new_record?
    end
  end
end
