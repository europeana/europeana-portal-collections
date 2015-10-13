module Browse
  class Colours < ApplicationView
    def page_title
      t('site.browse.colours.title')
    end

    def content
      {
        title: page_title,
        colours: {
          title: page_title,
          items: @colours.map do |colour|
            {
              hex: colour.value,
              num_results: colour.hits,
              url: search_path(f: { 'COLOURPALETTE' => [colour.value], 'TYPE' => ['IMAGE'] })
            }
          end
        }
      }
    end

    def head_meta
      [
        { meta_name: 'description', content: page_title }
      ] + super
    end
  end
end
