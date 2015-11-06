error_pages = [
  { title: 'Error', body: "We're sorry! The portal has encountered an error. A report has been automatically sent to the Europeana team to notify us. You can try to reload the page or do another search.", http_code: 500 },
  { title: 'Forbidden', body: 'You do not have permission to access this resource.', http_code: 403 },
  { title: "Sorry, we can't find that page", body: "Unfortunately we couldn't find the page you were looking for. Try searching Europeana or you might like the selected items below.", http_code: 404 },
  { title: 'Bad Request', body: 'There is a problem with your request.', http_code: 400 }
]
error_pages.each do |attrs|
  unless Page::Error.find_by_http_code(attrs[:http_code]).present?
    ActiveRecord::Base.transaction do
      page = Page::Error.create(attrs)
      page.publish!
    end
  end
end
