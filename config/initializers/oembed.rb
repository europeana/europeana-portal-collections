# Configure ruby-oembed
# @see https://github.com/judofyr/ruby-oembed

require 'oembed'

# Custom providers (not included in ruby-oembed)
sketchfab = OEmbed::Provider.new('https://sketchfab.com/oembed')
sketchfab << 'https://sketchfab.com/models/*'
dismarc = OEmbed::Provider.new('http://www.dismarc.org/player/oembed')
dismarc << 'http://eusounds.ait.co.at/player/*'
dismarc << 'http://www.dismarc.org/player/*'
britishlibrary = OEmbed::Provider.new('http://sounds.bl.uk/api/oembed')
britishlibrary << 'http://sounds.bl.uk/embed/*'
if ENV['ENABLE_EUSCREEN_OEMBED']
  euscreen = OEmbed::Provider.new('https://oembed.euscreen.eu/services/oembed')
  euscreen << 'http://www.euscreen.eu/item.html*'
end

# Europeana provider
europeana = OEmbed::Provider.new(ENV['EUROPEANA_OEMBED_PROVIDER'] || 'http://oembed.europeana.eu/')
europeana << 'http://www.ccma.cat/tv3/alacarta/programa/titol/video/*/'
europeana << 'http://www.ina.fr/video/*'
europeana << 'http://www.ina.fr/*/video/*'
europeana << 'http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=*'
europeana << 'https://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=*'
europeana << %r{\Ahttp://archives.crem-cnrs.fr/archives/items/[^/]+/\z}
europeana << 'http://www.theeuropeanlibrary.org/tel4/newspapers/issue/fullscreen/*'

# Register the providers to support
OEmbed::Providers.register(OEmbed::Providers::SoundCloud)
OEmbed::Providers.register(OEmbed::Providers::Vimeo)
OEmbed::Providers.register(OEmbed::Providers::Youtube)
OEmbed::Providers.register(sketchfab)
OEmbed::Providers.register(dismarc)
OEmbed::Providers.register(europeana)
OEmbed::Providers.register(britishlibrary)
OEmbed::Providers.register(euscreen) if ENV['ENABLE_EUSCREEN_OEMBED']
