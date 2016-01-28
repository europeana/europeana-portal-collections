# Configure ruby-oembed
# @see https://github.com/judofyr/ruby-oembed

require 'oembed'

# Custom providers (not included in ruby-oembed)
sketchfab = OEmbed::Provider.new('https://sketchfab.com/oembed')
sketchfab << 'https://sketchfab.com/models/*'

# Register the providers to support
OEmbed::Providers.register(OEmbed::Providers::SoundCloud)
OEmbed::Providers.register(OEmbed::Providers::Vimeo)
OEmbed::Providers.register(OEmbed::Providers::Youtube)
OEmbed::Providers.register(sketchfab)
