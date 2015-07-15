module Templates
  module Search
    class ChannelsLanding < ApplicationView
      def body_class
         'channel_landing'
      end

      def globalnav_options
        {
          search: false,
          myeuropeana: true
        }
      end

      def page_config
        {
          newsletter: true
        }
      end

      def content
        if(@channel.id == 'art')
          content_art
        elsif(@channel.id == 'music')
          content_music
        end
      end

      def navigation
        if(@channel.id == :music)
          return navigation_music
        end
        navigation_art
      end

      def content_common
        {
          name: t('site.channels.' + @channel.id.to_s + '.title'),
          description: t('site.channels.' + @channel.id.to_s + '.description')
        }
      end

      def content_art
        {
          channel_info: {
            name: content_common[:name],
            description: content_common[:description],
            stats: {
              items: [
                  {
                    count: '1,459,423',
                    text: t('site.channels.data-types.images'),
                    url: '#'
                  },
                  {
                    count: '393,117',
                    text: t('site.channels.data-types.texts'),
                    url: '#'
                  },
                  {
                    count: '1417',
                    text: t('site.channels.data-types.moving-images'),
                    url: '#'
                  },
                  {
                    count: '1001',
                    text: t('site.channels.data-types.3d'),
                    url: '#'
                  },
                  {
                    count: '300',
                    text: t('site.channels.data-types.sound'),
                    url: '#'
                  }
              ]
            },
            recent: {
              title: t('site.channels.labels.recent'),
              items: [
                {
                  text: 'Prado Museum',
                  url: '#',
                  number: '113' + ' ' + t('site.channels.data-types.count'),
                  date: 'May 2015'
                },
                {
                  text: 'Royal Armouries',
                  url: '#',
                  number: '6480' + ' ' + t('site.channels.data-types.count'),
                  date: 'May 2015'
                },
                {
                  text: 'British Library',
                  url: '#',
                  number: '33,326' + ' ' + t('site.channels.data-types.count'),
                  date: 'May 2015'
                }
              ],
              more_link: {
                text: t('global.more.load_more'),
                url: '#777'
              }
            },
            credits: {
              title: t('site.channels.labels.credits'),
              items: [
                {
                  text: 'National Gallery of Denmark',
                  url: '#777'
                },
                {
                  text: 'Rijksmuseum',
                  url: '#777'
                }
              ]
            }
          },
          hero_config: {
            hero_image: 'sample/channel_hero_art.jpg',
            attribution_text: 'The Riding School by Philips Wouverman',
            attribution_url: 'http://www.europeana.eu/portal/record/90402/SK_A_477.html',
            license_public: true
          },
          channel_entry: {
            title: 'Promoted title',
            items: [
              {
                title: 'All Paintings',
                url: root_url + 'channels/art?q=what:%20paintings',
                count: '190,226',
                media_type: 'Images',
                is_search: true,
                image: 'sample/entry-painting-square.jpg',
                image_alt: 'alt'
              },
              {
                title: 'All Sculptures',
                url: root_url + 'channels/art?q=what%3A%28sculpture+OR+sculptuur%20OR%20skulptur%29',
                count: '7,029',
                media_type: 'Images and video',
                is_search: true,
                image: 'sample/entry-sculpture-square.jpg',
                image_alt: 'alt'
              },
              {
                title: 'All Art history publications',
                url: root_url + 'channels/art?q=%28what%3A+%22art+history%22%29+OR+%28what%3A+%22http%3A%2F%2Fvocab.getty.edu%2Faat%2F300041273%22%29+OR+%28what%3A+histoire%20art%29+OR+%28what%3A+kunstgeschichte%29+OR+%28what%3A+%22estudio+de+la+historia+del+arte%22%29+OR+%28what%3A+Kunstgeschiedenis%29',
                count: '2,333',
                media_type: 'Documents',
                is_search: true,
                image: 'sample/entry-documents-square.jpg',
                image_alt: 'alt'
              },
              {
                title: 'Spotlight on Botticelli',
                url: root_url + 'channels/art?q=who:%20sandro%20botticelli',
                count: '76',
                media_type: 'Images and videos',
                is_spotlight: true,
                image: 'sample/entry-botticelli-square.jpg',
                image_alt: t('site.channels.featured.item-4')
              },
              {
                title: 'Spotlight on Alexander Roslin',
                url: root_url + 'channels/art?q=who:alexander%20roslin',
                count: '46',
                media_type: 'Images and documents',
                is_spotlight: true,
                image: 'sample/entry-roslin-square.jpg',
                image_alt: 'alt'
              },
              {
                title: 'Spotlight on Hokusai',
                url: root_url + 'channels/art?q=who:hokusai',
                count: '240',
                media_type: 'Images',
                is_spotlight: true,
                image: 'sample/entry-hokusai-square.jpg',
                image_alt: 'alt'
              }
            ]
          },
          promoted: {
            title: 'Promoted title',
            items: [
              {
                title: 'Royal Book Collections',
                url: 'http://exhibitions.europeana.eu/exhibits/show/royal-book-collections-en',
                is_exhibition: true,
                bg_image: 'sample/thumb-book.jpg'
              },
              {
                title: 'From Dada to Surrealism',
                url: 'http://exhibitions.europeana.eu/exhibits/show/dada-to-surrealism-en',
                is_exhibition: true,
                bg_image: 'sample/thumb-dada.jpg'
              },
              {
                title: 'Art Nouveau',
                url: 'http://exhibitions.europeana.eu/exhibits/show/art-nouveau-en%C2%A0',
                is_exhibition: true,
                bg_image: 'sample/thumb-artnouveau.jpg'
              },
              {
                title: 'Explore the World of Musical Instruments',
                url: 'http://exhibitions.europeana.eu/exhibits/show/musical-instruments-en',
                is_exhibition: true,
                bg_image: 'sample/thumb-instruments.jpg'
              },
              {
                title: 'Pablo Picasso',
                url: 'http://dizbi.hazu.hr/picasso/',
                is_exhibition: true,
                bg_image: 'sample/thumb-picasso.jpg'
              },
              {
                title: 'From Dada to Surrealism',
                url: 'http://exhibitions.europeana.eu/exhibits/show/dada-to-surrealism-en',
                is_exhibition: true,
                bg_image: 'sample/thumb-dada.jpg'
              }
            ]
          },
          news: {
            items: news_items,
          }
        }
      end

      def content_music
        {
          channel_info: {
            name: content_common[:name],
            description: content_common[:description],
            stats: {
              items: [
                  {
                    count: '216,014',
                    text: t('site.channels.data-types.images'),
                    url: '#'
                  },
                  {
                    count: '102,558',
                    text: t('site.channels.data-types.texts'),
                    url: '#'
                  },
                  {
                    count: '13,925',
                    text: t('site.channels.data-types.moving-images'),
                    url: '#'
                  },
                  {
                    count: '1001',
                    text: t('site.channels.data-types.3d'),
                    url: '#'
                  },
                  {
                    count: '450,068',
                    text: t('site.channels.data-types.sound'),
                    url: '#'
                  }
              ]
            },
            recent: {
              title: t('site.channels.labels.recent'),
              items: [
                {
                  text: 'Scala museum, Milan',
                  url: '#',
                  number: '1234' + ' ' + t('site.channels.data-types.count'),
                  date: 'July 2015'
                },
                {
                  text: 'Dresden Library',
                  url: '#',
                  number: '4377' + ' ' + t('site.channels.data-types.count'),
                  date: 'November 2014'
                },
                {
                  text: 'Rijksmuseum, Amsterdam',
                  url: '#',
                  number: '2169' + ' ' + t('site.channels.data-types.count'),
                  date: 'September 2014'
                }
              ],
              more_link: {
                text: 'Load more',
                url: '#777'
              }
            },
            credits: {
              title: t('site.channels.labels.credits'),
              items: [
                {
                  text: 'Deutsche National Bibliothek',
                  url: '#777'
                },
                {
                  text: 'Netherlands institute for sound and vision',
                  url: '#777'
                },
                {
                  text: 'Cité de la Musique',
                  url: '#777'
                }
              ]
            }
          },
          hero_config: {
            hero_image: 'sample/channel_hero_music.jpg',
            attribution_text: 'This is a placeholder image found somewhere',
            attribution_url: 'http://europeana.eu',
            license_CC_ND_NC_SA: true
          },
          channel_entry: {
            title: 'Promoted title',
            items: [
              {
                title: 'Erlkonig',
                url: 'urlhere',
                url: root_url + 'channels/music?q=erlkonig',
                count: '12',
                media_type: 'audio recordings'
              },
              {
                title: 'Mahler 5',
                url: root_url + 'channels/music?q=mahler',
                count: '15',
                media_type: 'video recordings'
              },
              {
                title: 'Beethoven\’s handwriting',
                url: root_url + 'channels/music?q=beethoven+writing',
                count: '2',
                media_type: 'scores'
              },
              {
                title: 'Haitink in Berlin',
                url: root_url + 'channels/music?q=Haitink',
                count: '12',
                media_type: 'letters'
              },
              {
                title: 'Papageno costumes',
                url: root_url + 'channels/music?q=Papageno+costumes',
                count: '42',
                media_type: 'images'
              },
              {
                title: 'Baroque wedding music',
                url: root_url + 'channels/music?q=Baroque+wedding',
                count: '5',
                media_type: 'audio recordings'
              }
            ]
          },
          promoted: {
            title: 'Promoted title',
            items: [
              {
                title: 'The legacy of Punk',
                url: 'urlhere',
                is_exhibition: true,
                bg_image: 'sample/thumb-music.jpg'
              },
              {
                title: 'Russian conductors in the EU',
                url: 'urlhere',
                is_exhibition: true,
                bg_image: 'sample/thumb-music.jpg'
              },
              {
                title: 'Famous Concert halls',
                url: 'urlhere',
                is_exhibition: true,
                bg_image: 'sample/thumb-music.jpg'
              },
              {
                title: 'Pop Music in 1980\'s Berlin',
                url: 'urlhere',
                is_exhibition: true,
                bg_image: 'sample/thumb-music.jpg'
              },
              {
                title: 'Music piracy',
                url: 'urlhere',
                is_exhibition: true,
                bg_image: 'sample/thumb-music.jpg'
              }
            ]
          },
          news: {
            items: news_items,
            blogurl: 'http://blog.europeana.eu/tag/#' + @channel.id
          }
        }
      end

      def navigation_common
        {
          global: {
            options: {
              search_active: false,
              settings_active: true
            },
            logo: {
              url: root_url,
              text: 'Europeana Search'
            },
            primary_nav: {
              items: [
                {
                  url: root_url,
                  text: 'Home',
                  is_current: false
                },
                {
                  url: root_url + 'channels/art',
                  text: 'Channels',
                  is_current: true,
                  submenu: {
                    items: [
                      {
                        url: root_url + 'channels/art',
                        text: 'Art History'
                      },
                      {
                        url: root_url + 'channels/music',
                        text: 'Music'
                      }
                    ]
                  }
                },
                {
                  url: 'http://exhibitions.europeana.eu/',
                  text: 'Exhibitions'
                },
                {
                  url: 'http://blog.europeana.eu/',
                  text: 'Blog'
                },
                {
                  url: root_url + 'myeuropeana#login',
                  text: 'My Europeana'
                }
              ]
            }  # end prim nav
          },
          footer: {
             linklist1: {
               title: t('global.more-info'),
               items: [
                 {
                   text: t('site.footer.menu.new-collections'),
                   url: '#'
                 },
                 {
                   text: t('site.footer.menu.data-providers'),
                   url: '#'
                 },
                 {
                   text: t('site.footer.menu.become-a-provider'),
                   url: '#'
                 }
               ]
             },
             linklist2: {
               title: t('global.help'),
               items: [
                 {
                   text: t('site.footer.menu.search-tips'),
                   url: '#'
                 },
                 {
                   text: t('site.footer.menu.using-myeuropeana'),
                   url: '#'
                 },
                 {
                   text: t('site.footer.menu.copyright'),
                   url: '#'
                 }
               ]
             },
             social: {
               googleplus: true,
               github: false
             }
           }
        }
      end

      def navigation_art
        {
          global: navigation_common[:global],
          footer: navigation_common[:footer]
        }
      end

      def navigation_music
        {
          global: navigation_common[:global],
          footer: navigation_common[:footer]
        }
      end
    end
  end
end
