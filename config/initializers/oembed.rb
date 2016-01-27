# Configure ruby-oembed
# @see https://github.com/judofyr/ruby-oembed

require 'oembed'

# Register the providers to support
OEmbed::Providers.register(OEmbed::Providers::SoundCloud)
OEmbed::Providers.register(OEmbed::Providers::Vimeo)
OEmbed::Providers.register(OEmbed::Providers::Youtube)
