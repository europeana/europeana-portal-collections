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
        @channel.id == :music ?
          content_music : content_art
      end
      
      def content_art
        {
          :channel_info  => {
            :name => "Europeana Art History",
            :description => "The <strong>Europeana Art History Channel</strong> brings you the lesser known as well as the famous pieces of European art combined with the books, letters, articles, videos and other material collated from our partner libraries, archives, and museums.",
            :stats  => {
              :items => [

                  {
                    :count => "1,459,423",
                    :text => "Images",
                    :url => "#"
                  },
                  {
                    :count => "393,117",
                    :text => "Texts",
                    :url => "#"
                  },
                  {
                    :count => "1417",
                    :text => "Moving images",
                    :url => "#"
                  },
                  {
                    :count => "1001",
                    :text => "3D objects",
                    :url => "#"
                  },
                  {
                    :count => "300",
                    :text => "Sound recordings",
                    :url => "#"
                  }
              ]
            },
            :recent => {
              :title => "Added recently:",
              :items => [
                {
                  :text => "Prado Museum",
                  :url => "#",
                  :number => "100 items",
                  :date => "May 2015"
                },
                {
                  :text => "Royal Armouries",
                  :url => "#",
                  :number => "6480 items",
                  :date => "May 2015"
                },
                {
                  :text => "British Library",
                  :url => "#",
                  :number => "33,326 items",
                  :date => "May 2015"
                }
              ],
              :more_link => {
                :text => "Load more",
                :url => "#777"
              }

            },
            :credits => {
              :title => "Curated by:",
              :items => [
                {
                  :text => "National Gallery of Denmark",
                  :url => "#777"
                },
                {
                  :text => "Rijksmuseum",
                  :url => "#777"
                }
              ]
            }
          },
          :hero_config =>{
            :hero_image =>"sample/channel_hero_art.jpg",
            :attribution_text => "The Riding School by Philips Wouverman",
            :attribution_url => "http://www.europeana.eu/portal/record/90402/SK_A_477.html",
            :license_public => true
          },
          :channel_entry =>{
            :title => "Promoted title",
            :items =>[
              {
                :title => "All Paintings",
                :url => root_url + "/channels/art?q=what:%20paintings",
                :count => "190,226",
                :media_type => "Images",
                :is_search => true,
                :image => "sample/entry-painting-square.jpg",
                :image_alt  => "alt"
              },
              {
                :title =>"All Sculptures",
                :url => root_url + "/channels/art?f%5BLANGUAGE%5D%5B%5D=nl&q=what%3A%28sculpture+OR+sculptuur%20OR%20skulptur%29",
                :count => "7,029",
                :media_type =>"Images and video",
                :is_search => true,
                :image => "sample/entry-sculpture-square.jpg",
                :image_alt  => "alt"
              },
              {
                :title =>"All Art history publications",
                :url => root_url + "/channels/art?f%5BTYPE%5D%5B%5D=TEXT&q=%28what%3A+%22art+history%22%29+OR+%28what%3A+%22http%3A%2F%2Fvocab.getty.edu%2Faat%2F300041273%22%29+OR+%28what%3A+histoire%20art%29+OR+%28what%3A+kunstgeschichte%29+OR+%28what%3A+%22estudio+de+la+historia+del+arte%22%29+OR+%28what%3A+Kunstgeschiedenis%29",
                :count => "2,333",
                :media_type =>"Documents",
                :is_search => true,
                :image => "sample/entry-documents-square.jpg",
                :image_alt  => "alt"
              },
              {
                :title =>"Spotlight on Botticelli",
                :url => root_url + "/channels/art?q=who:%20sandro%20botticelli",
                :count => "76",
                :media_type =>"Images and videos",
                :is_spotlight => true,
                :image => "sample/entry-botticelli-square.jpg",
                :image_alt  => "alt"
              },
              {
                :title =>"Spotlight on Alexander Roslin",
                :url => root_url + "/channels/art?q=who:alexander%20roslin",
                :count => "46",
                :media_type =>"Images and documents",
                :is_spotlight => true,
                :image => "sample/entry-roslin-square.jpg",
                :image_alt  => "alt"
              },
              {
                :title =>"Spotlight on Hokusai",
                :url => root_url + "/channels/art?q=who:hokusai",
                :count => "240",
                :media_type =>"Images",
                :is_spotlight => true,
                :image => "sample/entry-hokusai-square.jpg",
                :image_alt  => "alt"
              }              
            ]
          },
          :promoted =>{
            :title => "Promoted title",
            :items =>[
              {
                :title =>" Royal Book Collections",
                :url => "http://exhibitions.europeana.eu/exhibits/show/royal-book-collections-en",
                :is_exhibition => true,
                :bg_image => "sample/thumb-book.jpg"
              },
              {
                :title => "From Dada to Surrealism",
                :url => "http://exhibitions.europeana.eu/exhibits/show/dada-to-surrealism-en",
                :is_exhibition => true,
                :bg_image => "sample/thumb-dada.jpg"
              },
              {
                :title => "Art Nouveau",
                :url => "http://exhibitions.europeana.eu/exhibits/show/art-nouveau-en%C2%A0",
                :is_exhibition => true,
                :bg_image => "sample/thumb-artnouveau.jpg"
              },
              {
                :title => "Explore the World of Musical Instruments",
                :url => "http://exhibitions.europeana.eu/exhibits/show/musical-instruments-en",
                :is_exhibition => true,
                :bg_image => "sample/thumb-instruments.jpg"
              },
              {
                :title => "Pablo Picasso",
                :url => "http://dizbi.hazu.hr/picasso/",
                :is_exhibition => true,
                :bg_image => "sample/thumb-picasso.jpg"
              },
              {
                :title => "From Dada to Surrealism",
                :url => "http://exhibitions.europeana.eu/exhibits/show/dada-to-surrealism-en",
                :is_exhibition => true,
                :bg_image => "sample/thumb-dada.jpg"
              }
            ]
          },
          :news => {
             :items =>[
             {
               :headline => {
                 :medium => "The miniature magic of Japanese netsuke"
               },
               :url => "http://blog.europeana.eu/2015/04/the-miniature-magic-of-japanese-netsuke/",
               :img => {
                 :rectangle => {
                   :src => "sample/netsuke.jpg",
                   :alt => "Japanese scroll with netsuke illustration"
                 }
               },
               :excerpt => {
                 :short => "Netsuke, the small sculptural objects worn by men in Japan since the seventeenth century, first shot to fame in Europe with the publication of Edmund de Waal’s popular memoir, The Hare With Amber Eyes in 2010."
               } 
             },
             {
               :headline => {
                 :medium => "Celebrating World Theatre Day 2015"
               },
               :url => "http://blog.europeana.eu/2015/03/celebrating-world-theatre-day-2015/",
               :img => {
                 :rectangle => {
                   :src => "sample/theatreday.jpg",
                   :alt => "Theatre Day"
                 }
               },
               :excerpt => {
                 :short => "Today we celebrate World Theatre Day, an annual celebration where all International Theatre Institutes and the international theatre community organises theatre events."
               } 
             },
             {
               :headline => {
                 :medium => "Europeana takes part in #MuseumWeek 2015"
               },
               :url => "http://blog.europeana.eu/2015/03/europeana-takes-part-in-museumweek-2015/",
               :img => {
                 :rectangle => {
                   :src => "sample/Museumweek.jpg",
                   :alt => "Museum Week 2015"
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
      
      def content_music
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
            :items => news_items,
            :blogurl => "http://blog.europeana.eu/tag/#{@channel.id}"
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
              :url => "../../",
              :text => "Europeana Search"
            },
            :primary_nav =>{
              :items => [
                {
                  :url => root_url,
                  :text => "Home",
                  :is_current =>false
                },
                {
                  :url => root_url + "channels/art",
                  :text => "Channels",
                  :is_current =>true,
                  :submenu => {
                    :items => [
                      {
                        :url  => root_url + "channels/art",
                        :text => "Art History"
                      },
                      {
                        :url  => root_url + "channels/music ",
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
