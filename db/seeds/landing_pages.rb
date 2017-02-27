# @return [MediaObject]
def find_or_download_styleguide_image(path)
  url = "http://styleguide.europeana.eu/images/#{path}"
  url_hash = MediaObject.hash_source_url(url)
  media_object = MediaObject.find_or_initialize_by(source_url_hash: url_hash)
  if media_object.new_record?
    media_object.source_url = url
    media_object.save
    DownloadRemoteMediaObjectJob.perform_later(url)
  end
  media_object
end

unless Page::Landing.find_by_slug('collections/art').present?
  ActiveRecord::Base.transaction do
    art_hero = HeroImage.create(
      settings_attribution_title: 'Ships in a storm off a rocky coast',
      settings_attribution_creator: 'Jan Porcellis',
      settings_attribution_institution: 'Hallwylska museet',
      settings_attribution_url: '/portal/record/2048007/Athena_Plus_ProvidedCHO_Hallwylska_museet_14152.html',
      license: 'public',
      media_object: find_or_download_styleguide_image('sample/channel_hero_art.jpg')
    )
    art_landing = Page::Landing.create!(
      slug: 'collections/art',
      title: 'Europeana Art',
      body: 'From the Renaissance to the surrealists, and from ancient Roman sculpture to contemporary art, the Europeana Art and Art History Collection introduces you to artists and artworks from across the whole of Europe. [Something about interactive element]',
      strapline: 'Explore %{total_item_count} artworks, artefacts, books, videos and sounds from across Europe.',
      credits: [
        Link::Credit.new(url: 'http://www.smk.dk/', text: 'National Gallery of Denmark', position: 1),
        Link::Credit.new(url: 'https://www.rijksmuseum.nl/', text: 'Rijksmuseum', position: 2)
      ],
      hero_image: art_hero,
      promotions: [
        Link::Promotion.new(
          position: 1,
          url: 'http://exhibitions.europeana.eu/exhibits/show/royal-book-collections-en',
          text: 'Royal Book Collections',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-book.jpg')
        ),
        Link::Promotion.new(
          position: 2,
          url: 'http://exhibitions.europeana.eu/exhibits/show/dada-to-surrealism-en',
          text: 'From Dada to Surrealism',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-dada.jpg')
        ),
        Link::Promotion.new(
          position: 3,
          url: 'http://exhibitions.europeana.eu/exhibits/show/art-nouveau-en%C2%A0',
          text: 'Art Nouveau',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-artnouveau.jpg')
        ),
        Link::Promotion.new(
          position: 4,
          url: 'http://exhibitions.europeana.eu/exhibits/show/musical-instruments-en',
          text: 'Explore the World of Musical Instruments',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-instruments.jpg')
        ),
        Link::Promotion.new(
          position: 5,
          url: 'http://dizbi.hazu.hr/picasso/',
          text: 'Pablo Picasso',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-picasso.jpg')
        )
      ],
      browse_entries: [
        BrowseEntry.new(
          title: 'All Paintings',
          query: 'what:paintings',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-painting-square.jpg')
        ),
        BrowseEntry.new(
          title: 'All Sculptures',
          query: 'what:(sculpture OR sculptuur OR skulptur)',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-sculpture-square.jpg')
        ),
        BrowseEntry.new(
          title: 'All Art history publications',
          query: '(what: "art history") OR (what: "http://vocab.getty.edu/aat/300041273") OR (what: histoire art) OR (what: kunstgeschichte) OR (what: "estudio de la historia del arte") OR (what: Kunstgeschiedenis)',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-documents-square.jpg')
        ),
        BrowseEntry.new(
          title: 'Spotlight on Botticelli',
          query: 'who:sandro botticelli',
          subject_type: :person,
          media_object: find_or_download_styleguide_image('sample/entry-botticelli-square.jpg')
        ),
        BrowseEntry.new(
          title: 'Spotlight on Alexander Roslin',
          query: 'who:alexander roslin',
          subject_type: :person,
          media_object: find_or_download_styleguide_image('sample/entry-roslin-square.jpg')
        ),
        BrowseEntry.new(
          title: 'Spotlight on Hokusai',
          query: 'who:hokusai',
          subject_type: :person,
          media_object: find_or_download_styleguide_image('sample/entry-hokusai-square.jpg')
        ),
      ],
      feeds: [
        Feed.find_by_slug('art-blog')
      ]
    )
    art_landing.publish!
  end
end

unless Page::Landing.find_by_slug('').present?
  ActiveRecord::Base.transaction do
    home_hero = HeroImage.create!(
      settings_attribution_title: 'Insects and Fruit',
      settings_attribution_creator: 'Jan van Kessel',
      settings_attribution_institution: 'Rijksmuseum',
      settings_attribution_url: '/portal/record/90402/SK_A_793.html',
      settings_brand_opacity: 75,
      settings_brand_position: 'bottomleft',
      license: 'public',
      media_object: find_or_download_styleguide_image('sample/search_hero_1.jpg')
    )
    home_landing = Page::Landing.create!(
      slug: '',
      title: 'Home',
      strapline: 'Explore %{total_item_count} artworks, artefacts, books, videos and sounds from across Europe.',
      hero_image: home_hero,
      promotions: [
        Link::Promotion.new(
          position: 1,
          url: '/portal/collections/music',
          text: 'Music',
          settings_category: 'collection',
          settings_wide: '1',
          media_object: find_or_download_styleguide_image('sample/thumb-music.jpg')
        ),
        Link::Promotion.new(
          position: 2,
          url: 'http://exhibitions.europeana.eu/exhibits/show/recording-and-playing-machines',
          text: 'Recording and Playing Machines',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-machines.jpg')
        ),
        Link::Promotion.new(
          position: 3,
          url: 'https://www.google.com/culturalinstitute/exhibit/photography-on-a-silver-plate/gQxWH0VE?hl',
          text: 'Photography on a Silver Plate',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-photography.jpg')
        ),
        Link::Promotion.new(
          position: 4,
          url: 'http://exhibition.europeanfilmgateway.eu/efg1914/welcome',
          text: 'European Film and the First World War',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-expo-film.jpg')
        ),
        Link::Promotion.new(
          position: 5,
          url: 'http://www.europeana1914-1918.eu',
          text: 'Europeana 1914-1918',
          settings_category: 'featured_site',
          media_object: find_or_download_styleguide_image('sample/thumb-expo-film.jpg')
        ),
        Link::Promotion.new(
          position: 6,
          url: 'http://pro.europeana.eu/blogpost/reach-cultural-tourists-through-europeana-in-googles-field-trip',
          text: 'Europeana monuments now in Google Field Trip',
          settings_category: 'new'
        )
      ],
      feeds: [
          Feed.find_by_slug('all-blog')
      ]
    )
    home_landing.publish!
  end
end

unless Page::Landing.find_by_slug('collections/music').present?
  ActiveRecord::Base.transaction do
    music_hero = HeroImage.create!(
      settings_attribution_title: 'Danse de trois faunes et trois bacchantes',
      settings_attribution_creator: 'Hieronymus Hopfer',
      settings_attribution_institution: 'Bibliothèque municipale de Lyon',
      settings_attribution_url: '/portal/record/15802/eDipRouteurBML_eDipRouteurBML_aspx_Application_ESTA_26Action_RechercherDirectement_NUID___554__ESTA_3BAfficherVueSurEnregistrement_Vue_Fiche_Principal_3BAfficherFrameset.html',
      license: 'public',
      media_object: find_or_download_styleguide_image('sample/channel_hero_music.jpg')
    )
    music_landing = Page::Landing.create!(
      slug: 'collections/music',
      title: 'Europeana Music',
      strapline: 'Explore %{total_item_count} artworks, artefacts, books, videos and sounds from across Europe.',
      body: 'The <strong>Europeana Music Collection</strong> brings together the best music recordings, sheet music, and other music related collections from Europe\'s audio-visual archives, libraries, archives and museums. <a href="/portal/collections/music/about">Find out more about the Music Collection.</a>',
      hero_image: music_hero,
      credits: [
        Link::Credit.new(url: 'http://www.europeanasounds.eu/', text: 'Europeana Sounds')
      ],
      social_media: [
        Link::SocialMedia.new(url: 'https://twitter.com/eu_sounds', text: 'Europeana sounds on twitter (@eu_sounds)'),
        Link::SocialMedia.new(url: 'https://www.facebook.com/soundseuropeana', text: 'Europeana Sounds on facebook'),
        Link::SocialMedia.new(url: 'https://soundcloud.com/europeana', text: 'Europeana on Soundcloud')
      ],
      promotions: [
        Link::Promotion.new(
          position: 1,
          url: 'http://exhibitions.europeana.eu/exhibits/show/musical-instruments-en',
          text: 'Explore the World of Musical Instruments',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-instruments.jpg')
        ),
        Link::Promotion.new(
          position: 2,
          url: 'http://exhibitions.europeana.eu/exhibits/show/weddings-in-eastern-europe',
          text: 'Weddings in Eastern Europe',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-wedding.jpg')
        ),
        Link::Promotion.new(
          position: 3,
          url: 'http://exhibitions.europeana.eu/exhibits/show/recording-and-playing-machines',
          text: 'Recording and playing Machines',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-machines.jpg')
        ),
        Link::Promotion.new(
          position: 4,
          url: 'https://soundcloud.com/europeana',
          text: 'Find more from Europeana Music on Soundcloud',
          settings_wide: '1',
          settings_class: 'soundcloud',
          media_object: find_or_download_styleguide_image('sample/sc_st_white_240x140.png')
        )
      ],
      browse_entries: [
        BrowseEntry.new(
          title: 'Opera',
          query: 'what:(oper OR Óperas) OR title:oper OR (oper AND what:gesang)',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-opera-square.jpg')
        ),
        BrowseEntry.new(
          title: 'Folk Music',
          query: 'what:folk music',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-folk-square.jpg')
        ),
        BrowseEntry.new(
          title: 'Musical Instruments',
          query: 'PROVIDER:"MIMO - Musical Instrument Museums Online"',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-intruments-square.jpg')
        ),
        BrowseEntry.new(
          title: "Georges Bizet's Carmen",
          query: 'georges bizet carmen',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-carmen-square.jpg')
        ),
        BrowseEntry.new(
          title: 'Spotlight: The Lute',
          query: 'title:(lute OR luth) OR what:(lute OR luth)',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-lute-square.jpg')
        ),
        BrowseEntry.new(
          title: 'Spotlight: The Harpsichord',
          query: 'harpsichord',
          subject_type: :topic,
          media_object: find_or_download_styleguide_image('sample/entry-harpsichord-square.jpg')
        )
      ],
      feeds: [
        Feed.find_by_slug('music-blog')
      ]
    )
    music_landing.publish!
  end
end

unless Page::Landing.find_by_slug('collections/fashion').present?
  ActiveRecord::Base.transaction do
    fashion_landing = Page::Landing.create!(
      slug: 'collections/fashion',
      title: 'Europeana Fashion',
      settings_layout_type: 'browse',
      strapline: 'Discover %{total_item_count} historical dresses, accessories and catwalk photographs from across Europe.',
      body: '<b>Europeana Fashion</b> brings together more than 30 public and private archives and museums from across Europe in order give public access to high quality digital fashion content, ranging from historical dresses to accessories, catwalk photographs, drawings, sketches, videos, and fashion catalogues. Records ranging from historical dresses to accessoires, catwalk photographs, drawings, sketches, video\'s and fashion catalogues.',
      newsletter_url: 'http://europeanafashion.us5.list-manage.com/subscribe?u=08acbb4918e78ab1b8b1cb158&id=eeaec60e70',
      credits: [
        Link::Credit.new(url: 'http://www.europeanafashion.eu/portal/about.html', text: 'About Europeana Fashion')
      ],
      social_media: [
        Link::SocialMedia.new(url: 'http://www.twitter.com/europeanafashion', text: 'Twitter'),
        Link::SocialMedia.new(url: 'https://www.facebook.com/EuropeanaFashion', text: 'Facebook'),
        Link::SocialMedia.new(url: 'https://plus.google.com/115879951963722227275/posts', text: 'Google Plus'),
        Link::SocialMedia.new(url: 'http://instagram.com/europeanafashionofficial', text: 'Instagram'),
        Link::SocialMedia.new(url: 'http://www.pinterest.com/eurfashion/', text: 'Pinterest'),
        Link::SocialMedia.new(url: 'http://europeanafashion.tumblr.com/', text: 'Tumblr'),
        Link::SocialMedia.new(url: 'https://nl.linkedin.com/company/europeana', text: 'Linkedin')
      ],
      promotions: [
        Link::Promotion.new(
          position: 0,
          url: 'http://www.europeanafashion.eu/portal/themedetail.html#11',
          text: 'Prints!',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-instruments.jpg')
        ),
        Link::Promotion.new(
          position: 1,
          url: 'http://www.europeanafashion.eu/portal/themedetail.html#26',
          text: 'Monochromes',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-wedding.jpg')
        ),
        Link::Promotion.new(
          position: 2,
          url: 'http://www.europeanafashion.eu/portal/themedetail.html#15',
          text: 'Recording and playing Machines',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-machines.jpg')
        ),
        Link::Promotion.new(
          position: 3,
          url: 'http://www.europeanafashion.eu/portal/themedetail.html#21',
          text: 'Sportswear',
          settings_category: 'exhibition',
          media_object: find_or_download_styleguide_image('sample/thumb-machines.jpg')
        )
      ],
      feeds: [
        Feed.find_by_slug('fashion-blog'),
        Feed.find_by_slug('fashion-tumblr')
      ]
    )
    fashion_landing.publish!
  end
end
