error_pages = [
  { title: 'Error', body: "We're sorry! The portal has encountered an error. A report has been automatically sent to the Europeana team to notify us. You can try to reload the page or do another search.", http_code: 500, slug: 'errors/internal_server_error' },
  { title: 'Forbidden', body: 'You do not have permission to access this resource.', http_code: 403, slug: 'errors/forbidden' },
  { title: "Sorry, we can't find that page", body: "Unfortunately we couldn't find the page you were looking for. Try searching Europeana or you might like the selected items below.", http_code: 404, slug: 'errors/not_found' },
  { title: 'Bad Request', body: 'There is a problem with your request.', http_code: 400, slug: 'errors/bad_request' },
  { title: 'Invalid search query', body: 'Your search query is not valid, please try again or have a look at our <a href="/portal/help/search.html">search help page</a>.', http_code: 400, slug: 'exceptions/europeana/api/errors/request_error' } 
]
error_pages.each do |attrs|
  unless Page::Error.find_by_slug(attrs[:slug]).present?
    ActiveRecord::Base.transaction do
      page = Page::Error.create(attrs)
      page.publish!
    end
  end
end
