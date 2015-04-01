##
# Configure the stache gem
#
# @see https://github.com/agoragames/stache
Stache.configure do |c|
  # Use Mustache templates
  c.use :mustache

  # Use the Rails cache store
#  c.template_cache = Rails.cache
end
