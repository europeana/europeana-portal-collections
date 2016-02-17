module Browse
  class Colours < ApplicationView
    def page_title
      mustache[:page_title] ||= begin
        [t('site.browse.colours.title'), site_title].join(' - ')
      end
    end

    def content
      mustache[:content] ||= begin
        {
          title: page_title,
          description: t('site.browse.colours.description'),
          colours: {
            title: page_title,
            items: @colours.map do |colour|
              {
                hex: colour.value,
                label: t('X11.colours.' + (colour.value.sub '#', ''), locale: 'en', default: colour.value),
                num_results: colour.hits,
                url: colour_search_url(colour.value)
              }
            end
          }
        }
      end
    end

    def head_meta
      mustache[:head_meta] ||= begin
        [
          { meta_name: 'description', content: page_title }
        ] + super
      end
    end

    private

    def colour_search_url(colour)
      query_params = { f: { 'COLOURPALETTE' => [colour], 'TYPE' => ['IMAGE'] } }
      if @collection.present?
        collection_path(@collection, query_params)
      else
        search_path(query_params)
      end
    end

    def cache_body
      false
    end

    def body_cache_key
      'browse/colours' + (@collection.present? ? '/' + @collection.key : '')
    end
  end
end
