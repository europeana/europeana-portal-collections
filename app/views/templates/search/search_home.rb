module Templates
  module Search
    
    class SearchHome < ApplicationView
    
      
      def navigation
        {
          :global => navigation_global
        }
      end
      
      def content
        {
          :hero_config => {
            :hero_image  =>"sample/search_hero_1.jpg",
            :brand_position => "brand-bottomleft",
            :brand_opacity => "brand-opacity75",
            :attribution_text => "Insects and Fruit, Jan van Kessel",
            :attribution_url => "http://www.europeana.eu/portal/record/90402/SK_A_793.html",
            :license_CC_ND_NC_SA => false,
            :license_public  => true
          },
          :strapline  => t('site.home.strapline', total_item_count: total_item_count),
      
          :total_items  => "40,173,111",
            
          :important_removed  => {
            :text   => "Europeana stories are now in Google’s Field Trip app",
            :url    => "http://blog.europeana.eu/2015/03/its-your-world-explore-it-europeana-stories-now-in-googles-field-trip-app/"
          },

          :promoted => Europeana::Portal::Application.config.channels.select { |k, v| v[:home_bg_image].present? }.collect { |k, v|
            {
              title:      t(k, scope: 'global.channel'),
              url:        channel_path(k),
              is_channel: true,
              bg_image:   v[:home_bg_image]
            }
          } +
          [
            {
              :title  =>  "Europeana 1914—1918",
              :url  =>  "urlhere",
              :is_exhibition  =>  true,
              :bg_image  => "sample/thumb-1418.jpg"
            },
            {
              :title  => "Photography on a Silver Plate",
              :url    =>  "urlhere",
              :is_exhibition  =>  true,
              :bg_image  => "sample/thumb-photography.jpg"
            },
            {
              :title  => "European Film and the First World War",
              :url  =>  "urlhere",
              :is_exhibition  =>  true,
              :bg_image  =>  "sample/thumb-expo-film.jpg"
            },
            {
              :title     => "Europeana monuments now in Google Field Trip",
              :url       =>  "urlhere",
              :is_new    =>  true,
              :bg_image  => "sample/thumb-news.jpg"
            }
          ],
    
          :news  =>  {
            :items  => news_items
        }
      }
      end
    end
  end
end
