module Templates
  module Search
    
    class ChannelsLanding < ApplicationView
    
      
      def body_class
         "channel_landing"
      end
      
      
      def page_title
        "Europeana Search"
      end
      
      def globalnav_options
        {
          :search       =>  false,
          :myeuropeana  => true
        }
      end
            
      def page_config
        {
            :newsletter  => true
        }
      end
          
      #:css_files  => [
      #  {
      #    :path  =>  "../../css/search/screen.css",
      #    :media  => "all"
      #  }
      #],
      
      #:js_files  => [
      #  {
      #     :path => "../../js/dist/channels.js"
      #  },
      #  {
      #     :path => "../../js/dist/global.js"
      #  }
      #],

      #    :input_search => {
      #      :title => "Search Europeana Music",
      #      :input_name => "q",
      #      :placeholder => "Search Europeana Music"
      #    },
          
      
      def content
        {
          :channel_info  => {
            :name => "Europeana Music",
            :description => "<strong>Europeana Music</strong> brings together all music related cultural heritage from the Europeana collections",
            :stats  => {
              :items => [
                {
                  :count => "30,245",
                  :text  => "Audio Recordings",
                  :url   => "#"
                },
                {
                  :count => "11302",
                  :text  => "Images & photographs",
                  :url   => "#"
                },
                {
                  :count => "5904",
                  :text  => "Video Recordings",
                  :url   => "#"
                },
                {
                  :count => "1683",
                  :text  => "Scores",
                  :url   => "#"
                },
                {
                  :count => "1245",
                  :text  => "Letters",
                  :url   => "#"
                }
              ]
            },
            :recent => {
              :title => "Recent Additions",
              :items => [
                {
                  :text   => "Scala museum, Milan",
                  :url    => "#",
                  :number => "1234 items",
                  :date   => "July 2015"
                },
                {
                  :text   => "Dresden Library",
                  :url    => "#",
                  :number => "1234 items",
                  :date   => "November 2014"
                },
                {
                  :text   => "Rijksmuseum, Amsterdam",
                  :url    => "#",
                  :number => "1234 items",
                  :date   => "September 2014"
                }
              ],
              :more_link  => {
                :text  => "Load more",
                :url   => "#777"
              }
            },
            :credits => {
              :title => "Channel Curators",
              :items => [
                {
                  :text  => "Deutsche National Bibliothek",
                  :url   => "#777"
                },
                {
                  :text  => "Netherlands institute for sound and vision",
                  :url   => "#777"
                },
                {
                  :text => "Cité de la Musique",
                  :url => "#777"
                }
              ]
            }
          },
          :hero_config =>{
            :hero_image => "sample/channel_hero_music.jpg",
            :attribution_text => "This is a placeholder image found somewhere",
            :attribution_url => "http://europeana.eu",
           # :license_CC-ND-NC-SA => true
            :license_CC_ND_NC_SA => true
          },
          :channel_entry =>{
            :title => "Promoted title",
            :items =>[
              {
                :title =>"Erlkonig",
                :url => "urlhere",
                :count => "12",
                :media_type =>"audio recordings"
              },
              {
                :title => "Mahler 5",
                :url => "urlhere",
                :count =>  "12",
                :media_type => "video recordings"
              },
              {
                :title =>"Beethoven’s handwriting",
                :url => "urlhere",
                :count => "12",
                :media_type =>"scores"
              },
              {
                :title =>"Haitink in Berlin",
                :url => "urlhere",
                :count => "12",
                :media_type =>"letters"
              },
              {
                :title =>"Papageno costumes",
                :url => "urlhere",
                :count => "42",
                :media_type =>"images"
              },
              {
                :title =>"Baroque wedding music",
                :url => "urlhere",
                :count => "23",
                :media_type =>"audio recordings"
              }
            ]
          },
          :promoted =>{
            :title => "Promoted title",
            :items =>[
              {
                :title =>"The legacy of Punk",
                :url => "urlhere",
                :is_exhibition => true,
                :bg_image =>"sample/thumb-music.jpg"
              },
              {
                :title =>"Russian conductors in the EU",
                :url => "urlhere",
                :is_exhibition => true,
                :bg_image =>"sample/thumb-music.jpg"
              },
              {
                :title =>"Famous Concert halls",
                :url => "urlhere",
                :is_exhibition => true,
                :bg_image =>"sample/thumb-music.jpg"
              },
              {
                :title =>"Pop Music in 1980's Berlin",
                :url => "urlhere",
                :is_exhibition => true,
                :bg_image =>"sample/thumb-music.jpg"
              },
              {
                :title =>"Music piracy",
                :url => "urlhere",
                :is_exhibition => true,
                :bg_image =>"sample/thumb-music.jpg"
              }
            ]
          },
          :news => {
            :items =>[
            {
              :headline => {
                :medium =>"The miniature magic of Japanese netsuke"
              },
              :url => "http://blog.europeana.eu/2015/04/the-miniature-magic-of-japanese-netsuke/",
              :img => {
                :rectangle => {
                  :src =>"sample/netsuke.jpg",
                  :alt =>"Japanese scroll with netsuke illustration"
                }
              },
              :excerpt => {
                :short => "Netsuke, the small sculptural objects worn by men in Japan since the seventeenth century, first shot to fame in Europe with the publication of Edmund de Waal’s popular memoir, The Hare With Amber Eyes in 2010."
              } 
            },
            {
              :headline =>{
                :medium =>"Celebrating World Theatre Day 2015"
              },
              :url => "http://blog.europeana.eu/2015/03/celebrating-world-theatre-day-2015/",
              :img => {
                :rectangle => {
                  :src =>"sample/theatreday.jpg",
                  :alt =>"Theatre Day"
                }
              },
              :excerpt => {
                :short => "Today we celebrate World Theatre Day, an annual celebration where all International Theatre Institutes and the international theatre community organises theatre events."
              } 
            },
            {
              :headline =>{
                :medium =>"Europeana takes part in #MuseumWeek 2015"
              },
              :url => "http://blog.europeana.eu/2015/03/europeana-takes-part-in-museumweek-2015/",
              :img => {
                :rectangle => {
                  :src =>"sample/Museumweek.jpg",
                  :alt =>"Museum Week 2015"
                }
              },
              :excerpt => {
                :short => "Today marks the beginning of #MuseumWeek, an event to celebrate culture on Twitter. Museums from all over the world will be tweeting about their collections or sharing fun facts with their followers."
              } 
            }
            ]
          }
        }
      end
      
      def navigation
        {
          :global =>{
            :options => {
              :search_active => false,
              :settings_active => true
            },
            :logo =>{
              :url => "../templates-Search-Search-home/templates-Search-Search-home.html",
              :text => "Europeana Search"
            },
            :primary_nav =>{
              :items => [
                {
                  :url => "../templates-Search-Search-home/templates-Search-Search-home.html",
                  :text => "Home",
                  :is_current =>false
                },
                {
                  :url => "../templates-Search-Channels-landing-art/templates-Search-Channels-landing-art.html",
                  :text => "Channels",
                  :is_current =>true,
                  :submenu => {
                    :items => [
                      {
                        :url =>"../templates-Search-Channels-landing-art/templates-Search-Channels-landing-art.html",
                        :text => "Art History"
                      },
                      {
                        :url =>"../templates-Search-Channels-landing-music/templates-Search-Channels-landing-music.html",
                        :text => "Music"
                      }
                    ]
                  }
                },
                {
                  :url => "",
                  :text => "Exhibitions"
                },
                {
                  :url => "",
                  :text => "Blog"
                },
                {
                  :url => "",
                  :text => "My Europeana"
                }
              ]
            }  # end prim nav
          }, # end global
          
         
          :footer =>{
             :linklist1 =>{
               :title => "More info",
               :items => [
                 {
                   :text => "New collections",
                   :url =>"http://google.com"
                 },
                 {
                   :text => "All data providers",
                   :url =>"http://google.com"
                 },
                 {
                   :text => "Become a data provider",
                   :url =>"http://google.com"
                 }
               ]
             },
             :linklist2 =>{
               :title => "Help",
               :items => [
                 {
                   :text => "Search tips",
                   :url =>"http://google.com"
                 },
                 {
                   :text => "Using My Europeana",
                   :url =>"http://google.com"
                 },
                 {
                   :text => "Copyright",
                   :url =>"http://google.com"
                 }
               ]
             },
             :social =>{
               :googleplus => true,
               :github => false
             }
           }
         
         } # end navigation
      end  
    end
  end
end
