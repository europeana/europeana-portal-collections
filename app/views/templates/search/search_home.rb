module Templates
  module Search
    
    class SearchHome < ApplicationView
    
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
          :strapline  => "Explore 41,629,020 items from Europe's libraries, archives and museums. Books and manuscripts, photos and paintings, television and film, sculpture and crafts, diaries and maps, sheet music and recordings, they’re all here.",
      
          :total_items  => "40,173,111",
      
          :important  => {
            :text  => "It’s your world, explore it! — Europeana stories are now in Google’s Field Trip app",
            :url   => "http://blog.europeana.eu/2015/03/its-your-world-explore-it-europeana-stories-now-in-googles-field-trip-app/"
          },
      
          :promoted => [
            {
              :title  => "Art",
              :url  => "urlhere",
              :is_channel  => true,
              :bg_image  => "sample/thumb-art.jpg"
            },
            {
              :title      => "Music",
              :url        => "urlhere",
              :is_channel =>  true,
              :bg_image   => "sample/thumb-music.jpg"
            },
            {
              :title =>   "Maps and Cartography",
              :url   => "urlhere",
              :is_channel  =>  true,
              :bg_image  => "sample/thumb-maps.jpg"
            },
            {
              :title  =>  "Europeana 1914—1918",
              :url  =>  "urlhere",
              :is_exhibition  =>  true,
              :bg_image  => "sample/thumb-1418.jpg"
            },
            {
              :title  => "Natural History",
              :url  =>  "urlhere",
              :is_channel  =>  true,
              :bg_image  => "sample/thumb-naturalhistory.jpg"
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
            :items  => [
            {
              :headline  =>  {
                :medium  => "The miniature magic of Japanese netsuke"
              },
              :url  =>  "http://blog.europeana.eu/2015/04/the-miniature-magic-of-japanese-netsuke/",
              :img  =>  {
                :rectangle  =>  {
                  :src  => "sample/netsuke.jpg",
                  :alt  => "Japanese scroll with netsuke illustration"
                }
              },
              :excerpt  =>  {
                :short  =>  "Netsuke, the small sculptural objects worn by men in Japan since the seventeenth century, first shot to fame in Europe with the publication of Edmund de Waal’s popular memoir, The Hare With Amber Eyes in 2010."
              } 
            },
            {
              :headline  => {
                :medium  => "Celebrating World Theatre Day 2015"
              },
              :url  =>  "http://blog.europeana.eu/2015/03/celebrating-world-theatre-day-2015/",
              :img  =>  {
                :rectangle =>  {
                  :src   => "sample/theatreday.jpg",
                  :alt  =>  "Theatre Day"
                }
              },
              :excerpt  =>  {
                :short  =>  "Today we celebrate World Theatre Day, an annual celebration where all International Theatre Institutes and the international theatre community organises theatre events."
              } 
            },
            {
              :headline  => {
                :medium  => "Europeana takes part in #MuseumWeek 2015"
              },
              :url  =>  "http://blog.europeana.eu/2015/03/europeana-takes-part-in-museumweek-2015/",
              :img  =>  {
                :rectangle   =>  {
                  :src  => "sample/Museumweek.jpg",
                  :alt  => "Museum Week 2015"
                }
              },
              :excerpt   => {
                :short  =>  "Today marks the beginning of #MuseumWeek, an event to celebrate culture on Twitter. Museums from all over the world will be tweeting about their collections or sharing fun facts with their followers."
              } 
            }
          ]
        }
      }
      end
      
      def navigation
      {
        :global => {
          :options => {
            :search_active  => false,
            :settings_active  => true
          },
          :primary_nav  => {
            :items  => [
              {
                :url  => "#",
                :text  => "Home",
                :is_current  => true
              },
              {
                :url  => "",
                :text  => "Channels",
                :submenu  => {
                  :items  => [
                    {
                      :url  => "http://google.com",
                      :text  => "Channel 1"
                    },
                    {
                      :url  => "http://google.com",
                      :text  => "Channel 2",
                      :is_current  => true
                    },
                    {
                      :url  => "http://google.com",
                      :text  => "Channel 3"
                    }
                  ]
                }
              },
              {
                :url   =>  "",
                :text  =>  "Exhibitions"
              },
              {
                :url   => "",
                :text  => "Blog"
              },
              {
                :url   => "",
                :text  => "My Europeana"
              }
            ]
          }
        },
    
        :footer  => {
          :linklist1  => {
            :title  => "More info",
            :items  =>  [
              {
                :text  => "New collections",
                :url   => "http://google.com"
              },
              {
                :text => "All data providers",
                :url  => "http://google.com"
              },
              {
                :text =>  "Become a data provider",
                :url  => "http://google.com"
              }
            ]
          },
          :linklist2 => {
            :title  =>  "Help",
            :items  =>  [
              {
                :text => "Search tips",
                :url  => "http://google.com"
              },
              {
                :text =>  "Using My Europeana",
                :url  => "http://google.com"
              },
              {
                :text  => "Copyright",
                :url   => "http://google.com"
              }
            ]
          },
          :social  => {
            :googleplus =>  false,
            :github     =>  false
          }
        }    
      }
      end
      
      
    end  
    
  end
end
