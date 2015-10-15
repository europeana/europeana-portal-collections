# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

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

unless Page::Landing.find_by_slug('channels/art-history').present?
  ActiveRecord::Base.transaction do
    art_history_hero = HeroImage.create(
      settings_attribution_title: 'Ships in a storm off a rocky coast',
      settings_attribution_creator: 'Jan Porcellis',
      settings_attribution_institution: 'Hallwylska museet',
      settings_attribution_url: '/portal/record/2048007/Athena_Plus_ProvidedCHO_Hallwylska_museet_14152.html',
      license: 'public',
      media_object: find_or_download_styleguide_image('sample/channel_hero_art.jpg')
    )
    art_history_landing = Page::Landing.create!(
      slug: 'channels/art-history',
      title: 'Europeana Art History',
      body: 'From the Renaissance to the surrealists, and from ancient Roman sculpture to contemporary art, the Europeana Art and Art History Channel introduces you to artists and artworks from across the whole of Europe. [Something about interactive element]',
      credits: [
        Link::Credit.new(url: 'http://www.smk.dk/', text: 'National Gallery of Denmark', position: 1),
        Link::Credit.new(url: 'https://www.rijksmuseum.nl/', text: 'Rijksmuseum', position: 2)
      ],
      hero_image: art_history_hero,
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
          position: 1,
          title: 'All Paintings',
          query: 'what:paintings',
          settings_category: 'search',
          media_object: find_or_download_styleguide_image('sample/entry-painting-square.jpg')
        ),
        BrowseEntry.new(
          position: 2,
          title: 'All Sculptures',
          query: 'what:(sculpture OR sculptuur OR skulptur)',
          settings_category: 'search',
          media_object: find_or_download_styleguide_image('sample/entry-sculpture-square.jpg')
        ),
        BrowseEntry.new(
          position: 3,
          title: 'All Art history publications',
          query: '(what: "art history") OR (what: "http://vocab.getty.edu/aat/300041273") OR (what: histoire art) OR (what: kunstgeschichte) OR (what: "estudio de la historia del arte") OR (what: Kunstgeschiedenis)',
          settings_category: 'search',
          media_object: find_or_download_styleguide_image('sample/entry-documents-square.jpg')
        ),
        BrowseEntry.new(
          position: 4,
          title: 'Spotlight on Botticelli',
          query: 'who:sandro botticelli',
          settings_category: 'spotlight',
          media_object: find_or_download_styleguide_image('sample/entry-botticelli-square.jpg')
        ),
        BrowseEntry.new(
          position: 5,
          title: 'Spotlight on Alexander Roslin',
          query: 'who:alexander roslin',
          settings_category: 'spotlight',
          media_object: find_or_download_styleguide_image('sample/entry-roslin-square.jpg')
        ),
        BrowseEntry.new(
          position: 6,
          title: 'Spotlight on Hokusai',
          query: 'who:hokusai',
          settings_category: 'spotlight',
          media_object: find_or_download_styleguide_image('sample/entry-hokusai-square.jpg')
        ),
      ]
    )
    art_history_landing.publish!
  end
end

unless Channel.find_by_key('art-history').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'art-history',
      api_params: 'qf=(what: "fine art") OR (what: "beaux arts") OR (what: "bellas artes") OR (what: "belle arti") OR (what: "schone kunsten") OR (what:"konst") OR (what:"bildende kunst") OR (what: decorative arts) OR (what: konsthantverk) OR (what: "arts décoratifs") OR (what: paintings) OR (what: schilderij) OR (what: pintura) OR (what: peinture) OR (what: dipinto) OR (what: malerei) OR (what: måleri) OR (what: målning) OR (what: sculpture) OR (what: skulptur) OR (what: sculptuur) OR (what: beeldhouwwerk) OR (what: drawing) OR (what: poster) OR (what: tapestry) OR (what: jewellery) OR (what: miniature) OR (what: prints) OR (what: träsnitt) OR (what: holzschnitt) OR (what: woodcut) OR (what: lithography) OR (what: chiaroscuro) OR (what: "old master print") OR (what: estampe) OR (what: porcelain) OR (what: Mannerism) OR (what: Rococo) OR (what: Impressionism) OR (what: Expressionism) OR (what: Romanticism) OR (what: "Neo-Classicism") OR (what: "Pre-Raphaelite") OR (what: Symbolism) OR (what: Surrealism) OR (what: Cubism) OR (what: "Art Deco") OR (what: Dadaism) OR (what: "De Stijl") OR (what: "Pop Art") OR (what: "art nouveau") OR (what: "art history") OR (what: "http://vocab.getty.edu/aat/300041273") OR (what: "histoire de l\'art") OR (what: (art histoire)) OR (what: kunstgeschichte) OR (what: "estudio de la historia del arte") OR (what: Kunstgeschiedenis) OR (what: "illuminated manuscript") OR (what: buchmalerei) OR (what: enluminure) OR (what: "manuscrito illustrado") OR (what: "manoscritto miniato") OR (what: boekverluchting) OR (what: exlibris) OR (europeana_collectionName: "91631_Ag_SE_SwedishNationalHeritage_shm_art") OR (DATA_PROVIDER: "Institut für Realienkunde") OR (DATA_PROVIDER: "Bibliothèque municipale de Lyon") OR (DATA_PROVIDER:"Museu Nacional d\'Art de Catalunya") OR (DATA_PROVIDER:"Victoria \and Albert Museum") OR (PROVIDER:Ville+de+Bourg-en-Bresse) NOT (what: "printed serial" OR what:"printedbook" OR "printing paper" OR "printed music" OR DATA_PROVIDER:"NALIS Foundation" OR PROVIDER:"OpenUp!" OR PROVIDER:"BHL Europe" OR PROVIDER:"EFG - The European Film Gateway" OR DATA_PROVIDER: "Malta Aviation Museum Foundation")'
    ).publish!
  end
end

unless Channel.find_by_key('archaeology').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'archaeology',
      api_params: 'qf=(what: archaeology) OR (what: archäologie) OR (what: Altertümerkunde)
      OR (what: fornminne) OR (what: arqueologia) OR (what: archéologie) OR (what:
      arkeologi) OR (what: artefact) OR (what: artifact) OR (what: prehistory) OR
      (what: préhistoire) OR (what: urgeschichte) OR Palaeolit OR Paleoli OR
      neolitik OR neolithic OR mesolit OR "iron age" OR "bronze age" OR "stone age"
      OR (what: "rock art") OR (what: hällristning) OR (PROVIDER: CARARE) OR
      (PROVIDER: "3D ICONS") OR (DATA_PROVIDER: "The British Museum and The
      Portable Antiquities Scheme") OR (DATA_PROVIDER: "Rijksmuseum van Oudheden")
      NOT (DATA_PROVIDER: "Nederlands Architectuurinstituut" OR DATA_PROVIDER: "The
      National Architectural Heritage Board" OR DATA_PROVIDER: "Europeana
      1914-1918")'
    ).publish!
  end
end

unless Channel.find_by_key('architecture').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'architecture',
      api_params: 'qf=(what: architecture) OR (what: arkitektur) OR (what: architektur) OR
      (what: buildings) OR (what: ruin) OR DATA_PROVIDER: "Architekturmuseum der
      Technischen Universität Berlin in der Universitätsbibliothek" OR
      DATA_PROVIDER: "Nederlands Architectuurinstituut" OR DATA_PROVIDER:
      "The National Architectural Heritage Board" OR DATA_PROVIDER:
      "Vereniging De Hollandsche Molen"'
    ).publish!
  end
end

unless Channel.find_by_key('fashion').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'fashion',
      api_params: 'qf=(PROVIDER: "Europeana Fashion") OR (what: Fashion) OR (what: mode) OR (what: moda) OR (what: costume) OR (what: clothes) OR (what: shoes) OR (what: jewellery)'
    ).publish!
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
      hero_image: home_hero,
      promotions: [
        Link::Promotion.new(
          position: 1,
          url: '/portal/channels/music',
          text: 'Music',
          settings_category: 'channel',
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
      ]
    )
    home_landing.publish!
  end
end

unless Channel.find_by_key('home').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'home',
      api_params: '*:*'
    ).publish!
  end
end

unless Channel.find_by_key('maps').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'maps',
      api_params: 'qf=what:maps OR what:cartography OR what:kartografi OR what:cartographic OR what:geography OR what:geografi OR what:navigation OR what:chart OR what: portolan OR what: "mappa mundi" OR what: cosmography OR what:kosmografi OR what: "astronomical instrument" OR what:"celestial globe" OR title:cosmographia OR title:geographia OR title:geographica OR what:"aerial photograph" OR what:periplus OR what:atlas OR what:"armillary sphere" OR what:"terrestrial globe" OR what:"jordglob" OR what:globus NOT (PROVIDER:"OpenUp!")'
    ).publish!
  end
end

unless Page::Landing.find_by_slug('channels/music').present?
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
      slug: 'channels/music',
      title: 'Europeana Music',
      body: 'The <strong>Europeana Music Channel</strong> brings together the best music recordings, sheet music, and other music related collections from Europe\'s audio-visual archives, libraries, archives and museums. <a href="/portal/channels/music/about">Find out more about the Music Channel.</a>',
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
          position: 1,
          title: 'Opera',
          query: 'what:(oper OR Óperas) OR title:oper OR (oper AND what:gesang)',
          settings_category: 'search',
          media_object: find_or_download_styleguide_image('sample/entry-opera-square.jpg')
        ),
        BrowseEntry.new(
          position: 2,
          title: 'Folk Music',
          query: 'what:folk music',
          settings_category: 'search',
          media_object: find_or_download_styleguide_image('sample/entry-folk-square.jpg')
        ),
        BrowseEntry.new(
          position: 3,
          title: 'Musical Instruments',
          query: 'PROVIDER:"MIMO - Musical Instrument Museums Online"',
          settings_category: 'search',
          media_object: find_or_download_styleguide_image('sample/entry-intruments-square.jpg')
        ),
        BrowseEntry.new(
          position: 4,
          title: "Georges Bizet's Carmen",
          query: 'georges bizet carmen',
          settings_category: 'spotlight',
          media_object: find_or_download_styleguide_image('sample/entry-carmen-square.jpg')
        ),
        BrowseEntry.new(
          position: 5,
          title: 'Spotlight: The Lute',
          query: 'title:(lute OR luth) OR what:(lute OR luth)',
          settings_category: 'spotlight',
          media_object: find_or_download_styleguide_image('sample/entry-lute-square.jpg')
        ),
        BrowseEntry.new(
          position: 6,
          title: 'Spotlight: The Harpsichord',
          query: 'harpsichord',
          settings_category: 'spotlight',
          media_object: find_or_download_styleguide_image('sample/entry-harpsichord-square.jpg')
        )
      ]
    )
    music_landing.publish!
  end
end

unless Channel.find_by_key('music').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'music',
      api_params: 'qf=(PROVIDER:"Europeana Sounds" AND (what:music)) OR (DATA_PROVIDER:"National Library of Spain" AND TYPE:SOUND) OR (DATA_PROVIDER:"Sächsische Landesbibliothek - Staats- und Universitätsbibliothek Dresden" AND TYPE:SOUND) OR (PROVIDER:"DISMARC" AND NOT RIGHTS:*rr-p*) OR (PROVIDER: "MIMO - Musical Instrument Museums Online") OR ((what:music OR "performing arts") AND (DATA_PROVIDER:"Netherlands Institute for Sound and Vision")) OR ((what:music) AND (DATA_PROVIDER:"Open Beelden")) OR ((what:musique OR title:musique) AND (DATA_PROVIDER:"National Library of France")) OR ((what:musique OR title:musique) AND (DATA_PROVIDER:"The British Library")) OR ((what:musik OR what:oper OR title:musik OR title:oper) AND (DATA_PROVIDER:"Österreichische Nationalbibliothek - Austrian National Library") AND (TYPE:IMAGE))'
    ).publish!
  end
end

unless Channel.find_by_key('natural-history').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'natural-history',
      api_params: 'qf=(what: natural history) OR ("histoire naturelle") OR (naturgeschichte) OR ("historia naturalna") OR ("historia natural") OR (what: biology) OR (what: geology) OR (what: zoology) OR (what:entomology) OR (what:ornithology) OR (what:mycology) OR (what: specimen) OR (what: fossil) OR (what:animal) OR (what:flower) OR (what:palaeontology) OR (what:paleontology) OR (what:flora) OR (what:fauna) OR ((title:fauna AND TYPE:TEXT)) OR ((title:flora AND TYPE:TEXT)) OR (what:evolution) OR (what:systematics) OR (what:systematik) OR (what:plant) OR (what:insect) OR (what:insekt) OR (herbarium) OR (carl linnaeus) OR (Carl von Linné) OR (Leonhart Fuchs) OR (Otto Brunfels) OR (Hieronymus Bock) OR (Valerius Cordus) OR (Konrad Gesner) OR (Frederik Ruysch) OR (Gaspard Bauhin) OR (Henry Walter Bates) OR (Charles Darwin) OR (Alfred Russel Wallace) OR (Georges Buffon) OR (Jean-Baptiste de Lamarck) OR (Maria Sibylla Merian) OR (naturalist) OR (de materia media) OR (historiae animalium) OR (systema naturae) OR (botanica) OR (plantarum) OR (PROVIDER:"OpenUp!") OR (PROVIDER:"STERNA") OR (PROVIDER:"The Natural Europe Project") OR (PROVIDER:"BHL Europe") NOT (DATA_PROVIDER:"askabaoutireland.ie")'
    ).publish!
  end
end

unless Channel.find_by_key('newspapers').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'newspapers',
      api_params: 'qf=what:newspapers'
    ).publish!
  end
end

unless Channel.find_by_key('performing-arts').present?
  ActiveRecord::Base.transaction do
    Channel.create!(
      key: 'performing-arts',
      api_params: 'qf=(what: "performance art") OR (what: "performing arts") OR (what:
      theatre) OR (what: pantomime) OR (what: puppetry) OR (what: "puppet theatre")
      OR (what: ballet) OR (what: opera) OR (what: dance) OR (what: circus) OR
      (what: cirkus) OR (what: noh) OR (kabuki) OR ("wayang kulit") OR (Karagöz) OR
      (what: choreography) OR (DATA_PROVIDER:"Österreichisches Theatermuseum") OR
      (DATA_PROVIDER: "Arts and Theatre Institute") OR (PROVIDER: "ECLAP, e-library
      for Performing Arts") OR (who: aischylos) OR (who: euripedes) OR (who:
      aristophanes) OR (who: sofokles) OR (who: (william shakespeare)) OR (who:
      (lope de vega)) OR (who: (jean racine)) OR (who: Molière) OR (who: (friedrich
      schiller)) OR (who: (henrik ibsen)) NOT (DATA_PROVIDER: "Progetto ArtPast-
      CulturaItalia")'
    ).publish!
  end
end

unless Banner.find_by_key('phase-feedback').present?
  ActiveRecord::Base.transaction do
    Banner.create!(
      key: 'phase-feedback',
      title: 'This is an Alpha release of our new collections search and Music Channel',
      body: 'An Alpha release means that this website is in active development and will be updated regularly. It may sometimes be offline. Your feedback will help us improve our site.',
      link: Link.new(
        url: 'http://insights.hotjar.com/s?siteId=54631&surveyId=2939',
        text: 'Give us your input!'
      )
    ).publish!
  end
end

unless Page.find_by_slug('about').present?
  ActiveRecord::Base.transaction do
    Page.create!(
      slug: 'about',
      title: 'Welcome, culture lover!',
      body: '<p>Whether you came here for inspiration, to work on your research, looking for your next coffee mug design or just to snoop around, we hope you will find what you need somewhere amongst the 45 million objects we host here.</p><p>Our material comes from all over Europe and the scope of the collections is really quite astonishing. Our aim is help you find your way round so you discover treasures of your own.</p><p>Over the last few years, we’ve been expanding our collections and learning more and more about them, and what you want to do with them. Now it’s time to change a few things and make some improvements to our service!</p><p>We’re trying out a new version of Europeana Collections. We are working hard to improve your experience here and make it as easy as possible for you to find the information you are looking for. So we’ll probably ask you to help us by answering some questions. Your answers will be really helpful to us, so please do take a moment to give us your thoughts. Thanks!</p><p>In the meantime, we hope you enjoy your cultural journey with us.</p>'
    ).publish!
  end
end

unless Page.find_by_slug('channels/music/about').present?
  ActiveRecord::Base.transaction do
    Page.create!(
      slug: 'channels/music/about',
      title: 'About the Music Channel',
      body: '<p>Imagine looking at original handwritten manuscripts of a piece of music while listening to different interpretations of it, and reading a biography of the composer. On the Europeana Music Channel, you can.</p><p><a href="http://www.europeanasounds.eu/">Our partners</a>, all experts in music, from across Europe have carefully curated this collection of music recordings, sheet music, images of musical instruments, books about music and other music-related content. </p><p>We’ve made this early test version of the Music Channel available to you, our users, so you can help us shape it as we develop it further. So when you visit the site you will at times be asked to answer questions or surveys that appear on screen. We would really appreciate if you could take the time to answer those questions and surveys!</p><p>Also, in the interest of transparency and privacy, you should know that we log user statistics and user behaviour in Google Analytics and a service called Hotjar. We do that because it shows us where we’ve gone wrong in our designs and so helps us to improve the Music Channel. All logs are kept private and anonymised and will only be used to improve our service.</p><p>We encourage you to search the collection, play music, view the sheet music or read around it. When copyright allows, you can download the things you love most. And visit our virtual exhibitions to discover music in ways you’ve never done before!</p>'
    ).publish!
  end
end

error_pages = [
  { title: 'Internal Server Error', body: 'Something went wrong.', http_code: 500 },
  { title: 'Forbidden', body: 'You do not have permission to access this resource.', http_code: 403 },
  { title: "Sorry, we can't find that page", body: "Unfortunately we couldn't find the page you were looking for. Try searching Europeana or you might like the selected items below.", http_code: 404 }
]
error_pages.each do |attrs|
  ActiveRecord::Base.transaction do
    page = Page::Error.create(attrs)
    page.publish!
  end
end
