# Configure ruby-oembed
# @see https://github.com/judofyr/ruby-oembed

require 'oembed'

# Custom providers (not included in ruby-oembed)
sketchfab = OEmbed::Provider.new('https://sketchfab.com/oembed')
sketchfab << 'https://sketchfab.com/models/*'

# Europeana provider
europeana = OEmbed::Provider.new(ENV['EUROPEANA_OEMBED_PROVIDER'] || 'http://oembed.europeana.eu/')
europeana << 'http://www.ccma.cat/tv3/alacarta/programa/titol/video/*/'
europeana << 'http://www.ina.fr/video/*'
europeana << 'http://www.ina.fr/*/video/*'
europeana << 'http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=*'
europeana << 'https://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=*'

# Register the providers to support
OEmbed::Providers.register(OEmbed::Providers::SoundCloud)
OEmbed::Providers.register(OEmbed::Providers::Vimeo)
OEmbed::Providers.register(OEmbed::Providers::Youtube)
OEmbed::Providers.register(sketchfab)
OEmbed::Providers.register(europeana)
