module Browse
  class Colours < ApplicationView
    def page_title
      mustache[:page_title] ||= begin
        t('site.browse.colours.title')
      end
    end

    def content
      mustache[:content] ||= begin
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
    end

    def head_meta
      mustache[:head_meta] ||= begin
        [
          { meta_name: 'description', content: page_title }
        ] + super
      end
    end
  end
end
