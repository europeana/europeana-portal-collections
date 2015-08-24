##
# Configure the stache gem
#
# @see https://github.com/agoragames/stache
Stache.configure do |c|
  # Use Mustache templates
  c.use :mustache

  # Store compiled templates in memory
  # (stache template cache does not work with Redis; see
  # https://github.com/agoragames/stache/issues/58)
  c.template_cache = ActiveSupport::Cache::MemoryStore.new
end
