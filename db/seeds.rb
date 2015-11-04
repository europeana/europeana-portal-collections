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

unless Page::Landing.find_by_slug('collections/art-history').present?
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
      slug: 'collections/art-history',
      title: 'Europeana Art History',
      body: 'From the Renaissance to the surrealists, and from ancient Roman sculpture to contemporary art, the Europeana Art and Art History Collection introduces you to artists and artworks from across the whole of Europe. [Something about interactive element]',
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

unless Collection.find_by_key('art-history').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
      key: 'art-history',
      api_params: 'qf=(what: "fine art") OR (what: "beaux arts") OR (what: "bellas artes") OR (what: "belle arti") OR (what: "schone kunsten") OR (what:"konst") OR (what:"bildende kunst") OR (what: decorative arts) OR (what: konsthantverk) OR (what: "arts décoratifs") OR (what: paintings) OR (what: schilderij) OR (what: pintura) OR (what: peinture) OR (what: dipinto) OR (what: malerei) OR (what: måleri) OR (what: målning) OR (what: sculpture) OR (what: skulptur) OR (what: sculptuur) OR (what: beeldhouwwerk) OR (what: drawing) OR (what: poster) OR (what: tapestry) OR (what: jewellery) OR (what: miniature) OR (what: prints) OR (what: träsnitt) OR (what: holzschnitt) OR (what: woodcut) OR (what: lithography) OR (what: chiaroscuro) OR (what: "old master print") OR (what: estampe) OR (what: porcelain) OR (what: Mannerism) OR (what: Rococo) OR (what: Impressionism) OR (what: Expressionism) OR (what: Romanticism) OR (what: "Neo-Classicism") OR (what: "Pre-Raphaelite") OR (what: Symbolism) OR (what: Surrealism) OR (what: Cubism) OR (what: "Art Deco") OR (what: Dadaism) OR (what: "De Stijl") OR (what: "Pop Art") OR (what: "art nouveau") OR (what: "art history") OR (what: "http://vocab.getty.edu/aat/300041273") OR (what: "histoire de l\'art") OR (what: (art histoire)) OR (what: kunstgeschichte) OR (what: "estudio de la historia del arte") OR (what: Kunstgeschiedenis) OR (what: "illuminated manuscript") OR (what: buchmalerei) OR (what: enluminure) OR (what: "manuscrito illustrado") OR (what: "manoscritto miniato") OR (what: boekverluchting) OR (what: exlibris) OR (europeana_collectionName: "91631_Ag_SE_SwedishNationalHeritage_shm_art") OR (DATA_PROVIDER: "Institut für Realienkunde") OR (DATA_PROVIDER: "Bibliothèque municipale de Lyon") OR (DATA_PROVIDER:"Museu Nacional d\'Art de Catalunya") OR (DATA_PROVIDER:"Victoria \and Albert Museum") OR (PROVIDER:Ville+de+Bourg-en-Bresse) NOT (what: "printed serial" OR what:"printedbook" OR "printing paper" OR "printed music" OR DATA_PROVIDER:"NALIS Foundation" OR PROVIDER:"OpenUp!" OR PROVIDER:"BHL Europe" OR PROVIDER:"EFG - The European Film Gateway" OR DATA_PROVIDER: "Malta Aviation Museum Foundation")'
    ).publish!
  end
end

unless Collection.find_by_key('archaeology').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
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

unless Collection.find_by_key('architecture').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
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

unless Collection.find_by_key('fashion').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
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
      ]
    )
    home_landing.publish!
  end
end

unless Collection.find_by_key('home').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
      key: 'home',
      api_params: '*:*'
    ).publish!
  end
end

unless Collection.find_by_key('maps').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
      key: 'maps',
      api_params: 'qf=what:maps OR what:cartography OR what:kartografi OR what:cartographic OR what:geography OR what:geografi OR what:navigation OR what:chart OR what: portolan OR what: "mappa mundi" OR what: cosmography OR what:kosmografi OR what: "astronomical instrument" OR what:"celestial globe" OR title:cosmographia OR title:geographia OR title:geographica OR what:"aerial photograph" OR what:periplus OR what:atlas OR what:"armillary sphere" OR what:"terrestrial globe" OR what:"jordglob" OR what:globus NOT (PROVIDER:"OpenUp!")'
    ).publish!
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

unless Collection.find_by_key('music').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
      key: 'music',
      api_params: 'qf=(PROVIDER:"Europeana Sounds" AND (what:music)) OR (DATA_PROVIDER:"National Library of Spain" AND TYPE:SOUND) OR (DATA_PROVIDER:"Sächsische Landesbibliothek - Staats- und Universitätsbibliothek Dresden" AND TYPE:SOUND) OR (PROVIDER:"DISMARC" AND NOT RIGHTS:*rr-p*) OR (PROVIDER: "MIMO - Musical Instrument Museums Online") OR ((what:music OR "performing arts") AND (DATA_PROVIDER:"Netherlands Institute for Sound and Vision")) OR ((what:music) AND (DATA_PROVIDER:"Open Beelden")) OR ((what:musique OR title:musique) AND (DATA_PROVIDER:"National Library of France")) OR ((what:musique OR title:musique) AND (DATA_PROVIDER:"The British Library")) OR ((what:musik OR what:oper OR title:musik OR title:oper) AND (DATA_PROVIDER:"Österreichische Nationalbibliothek - Austrian National Library") AND (TYPE:IMAGE))'
    ).publish!
  end
end

unless Collection.find_by_key('natural-history').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
      key: 'natural-history',
      api_params: 'qf=(what: natural history) OR ("histoire naturelle") OR (naturgeschichte) OR ("historia naturalna") OR ("historia natural") OR (what: biology) OR (what: geology) OR (what: zoology) OR (what:entomology) OR (what:ornithology) OR (what:mycology) OR (what: specimen) OR (what: fossil) OR (what:animal) OR (what:flower) OR (what:palaeontology) OR (what:paleontology) OR (what:flora) OR (what:fauna) OR ((title:fauna AND TYPE:TEXT)) OR ((title:flora AND TYPE:TEXT)) OR (what:evolution) OR (what:systematics) OR (what:systematik) OR (what:plant) OR (what:insect) OR (what:insekt) OR (herbarium) OR (carl linnaeus) OR (Carl von Linné) OR (Leonhart Fuchs) OR (Otto Brunfels) OR (Hieronymus Bock) OR (Valerius Cordus) OR (Konrad Gesner) OR (Frederik Ruysch) OR (Gaspard Bauhin) OR (Henry Walter Bates) OR (Charles Darwin) OR (Alfred Russel Wallace) OR (Georges Buffon) OR (Jean-Baptiste de Lamarck) OR (Maria Sibylla Merian) OR (naturalist) OR (de materia media) OR (historiae animalium) OR (systema naturae) OR (botanica) OR (plantarum) OR (PROVIDER:"OpenUp!") OR (PROVIDER:"STERNA") OR (PROVIDER:"The Natural Europe Project") OR (PROVIDER:"BHL Europe") NOT (DATA_PROVIDER:"askabaoutireland.ie")'
    ).publish!
  end
end

unless Collection.find_by_key('newspapers').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
      key: 'newspapers',
      api_params: 'qf=what:newspapers'
    ).publish!
  end
end

unless Collection.find_by_key('performing-arts').present?
  ActiveRecord::Base.transaction do
    Collection.create!(
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
      title: 'This is an Alpha release of our new collections search and Music Collection',
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

unless Page.find_by_slug('collections/music/about').present?
  ActiveRecord::Base.transaction do
    Page.create!(
      slug: 'collections/music/about',
      title: 'About the Music Collection',
      body: '<p>Imagine looking at original handwritten manuscripts of a piece of music while listening to different interpretations of it, and reading a biography of the composer. On the Europeana Music Collection, you can.</p><p><a href="http://www.europeanasounds.eu/">Our partners</a>, all experts in music, from across Europe have carefully curated this collection of music recordings, sheet music, images of musical instruments, books about music and other music-related content. </p><p>We’ve made this early test version of the Music Collection available to you, our users, so you can help us shape it as we develop it further. So when you visit the site you will at times be asked to answer questions or surveys that appear on screen. We would really appreciate if you could take the time to answer those questions and surveys!</p><p>Also, in the interest of transparency and privacy, you should know that we log user statistics and user behaviour in Google Analytics and a service called Hotjar. We do that because it shows us where we’ve gone wrong in our designs and so helps us to improve the Music Collection. All logs are kept private and anonymised and will only be used to improve our service.</p><p>We encourage you to search the collection, play music, view the sheet music or read around it. When copyright allows, you can download the things you love most. And visit our virtual exhibitions to discover music in ways you’ve never done before!</p>'
    ).publish!
  end
end

unless Page.find_by_slug('contact').present?
  ActiveRecord::Base.transaction do
    Page.create!(
      slug: 'contact',
      title: 'Contact us',
      body: '<p>
        Europeana is being temporarily rehoused due to works at the Koninklijke Bibliotheek. In 2015 you will find us at:<br/>
          <br/>
        Europeana Foundation<br/>
        Stichthage building, 9th floor<br/>
        Koningin Julianaplein 10,<br/>
        2595 AA<br/>
        The Hague<br/>
        The Netherlands<br/>
        </p>
      <h4>To be added to the press list or for general communications</h4>
      <p>
          <a href="mailto:Eleanor.Kenny@bl.uk">Eleanor Kenny</a>
            <br/>
          Head of Communications<br/>
          </p>
      <h4>To contribute content to Europeana</h4>
      <p>
        See the <a href="http://pro.europeana.eu/share-your-data/">content providers</a> page on our project site
      </p>'
    ).publish!
  end
end

unless Page.find_by_slug('help').present?
  ActiveRecord::Base.transaction do
    Page.create!(
      slug: 'help',
      title: 'Help',
      body: '<p>Welcome to Europeana. This page describes some of the things that you can do while you are here. Learn more about:</p>

<ul class="zero">
<li><strong>Searching Europeana</strong>: Search tips, Refined search, Phrase search, Exclude words, Auto-completion, Spelling suggestions.</li>

<li><strong>Exploring Europeana</strong>: Through time, On a map, With curatorial expertise.</li>


<li><strong>Results in Europeana</strong>: Seeing further details, Rights and license information, Translating details, Searching on external services, New related searches on Europeana, Viewing item on provider\'s site, Embedding, and Citing.</li>

<li><strong>Using My Europeana</strong>: Saving searches, Saving items, and Adding tags.</li>
</ul>'
    ).publish!
  end
end

unless Page.find_by_slug('help/search').present?
  ActiveRecord::Base.transaction do
    Page.create!(
      slug: 'help/search',
      title: 'Searching Europeana',
      body: '<p>Welcome to Europeana. This page describes some of the things that you can do while you are here. Learn more about:
  <ul class="zero">
    <li><strong>Searching Europeana</strong>: Search tips, refined search, phrase search, exclude words, auto-completion, filter results, share your search.</li>
    <li><strong>Exploring Europeana</strong>: exhibitions, new content.</li>
    <li><strong>Results in Europeana</strong>: Seeing further details, rights and licence information, translating details, searching on external services, related searches on Europeana, viewing item on provider\'s site, embedding, and citing.</li>
    <li><strong>Using My Europeana</strong>: Saving searches, saving items, and adding tags.</li>
  </ul>

<h2>General Search</h2>

<p>Searching the millions of items in Europeana is simple. Just enter your search term and hit <strong>Search</strong>.</p>

<h2>Specific search</h2>

<p>You can narrow your search with the arrow to the right of <b>Search All fields</b> and selecting a category: <strong>Titles, Creators, Subjects, Dates/Periods, Places</strong>. Then enter your search term and hit <strong>Search</strong>.</p>

<p>Alternatively, just ask yourself who, what, where or when you are interested in and type these words into Europeana\'s search box followed by a colon (:). Then enter your search term and hit <strong>Search</strong>.</p>

<p>For specific searches, you could:</p>
  <ul>
    <li>Use the <strong>Creator</strong> filter or enter <strong>who:</strong> followed by a name of, for example, an actor, author or architect. Your results will display only items for which the name you entered is listed as the creator. For example, searching for <a href="search.html?query=who%3A+Vincent+van+Gogh">who: Vincent van Gogh</a> will narrow your results to van Gogh\'s works, excluding photographs of the artist or documentaries about him and his work.</li>
    <li>Use the <strong>Subject</strong> or <strong>Title</strong> filter or enter <strong>what:</strong> followed by a type of item, a subject you are interested in or words from the title of the item you are looking for. Your search results will display only items of the requested type or subject or items whose title includes your search term. For example, searching for <a href="search.html?query=what%3A+maps">what: maps</a> will narrow your results to maps, or <a href="search.html?query=what%3A+art+nouveau">what: Art Nouveau</a> will display artworks, buildings and monuments done in the Art Nouveau style.</li>
    <li>Use the <strong>Place</strong> filter or enter <strong>where:</strong> followed by a name of a town, city or country within Europe or around the world. Your search results will display only items which were created in, published in or depict the place you are searching for. For example, searching for <a href="search.html?query=where%3A+milan">where: Milan</a> will help you differentiate your search when you are looking only for objects created or held in Milan, excluding items on writer Milan Kundera from your search results.</li>
    <li>Use the <strong>Date</strong> filter or enter <strong>when:</strong> followed by a date (e.g. 1945) or a period (e.g. Roman or Medieval). Your search results will display only items for which the date is listed in the item\'s date field. For example, searching for <a href="search.html?query=when%3A+1984">when: 1984</a> will help you differentiate your search when you are looking only for items dated 1984, excluding items that have 1984 in their title or description, like George Orwell\'s novel.</li>
  </ul>

<p>These search functions also have support for different spellings and languages. For example, when you search for <a href="search.html?query=where%3A+milan">where: Milan</a>, the results will also include items with Milano, Mailand or Milanas listed as their geographic coverage.</p>

<h2>Phrase search</h2>

<p><b>Phrase search</b> is also possible. Just put <b>quotation marks</b> (e.g. &ldquo;art nouveau&rdquo;) around the phrase you want to find, or type <strong>AND</strong> between the keywords (e.g. art <b>AND</b> nouveau).</p>

<p><b>Exclude words</b> by typing <strong>NOT</strong> in capital letters, followed by the word you want to omit (e.g. Auguste <b>NOT</b> Renoir)</p>

<p>Another helpful search feature is <b>Auto completion</b>. Start typing a search term. Europeana will suggest words that may match what you are thinking of. Just select the term you want and hit <strong>Search</strong></p>

<h2>Refine your search</h2>

 <p>Once you have done an initial search, results can be narrowed down with the <strong>Refine your search</strong> functions. These are in the grey pane on the search results screen. You can add more keywords to your search, thereby narrowing the search results. Just type your keyword into the <strong>Add more keywords</strong> field and hit <strong>+ Add</strong>. The keyword is displayed at the top of the pane, under <b>Matches for.</b></p>

<p>To remove a keyword, hit the X icon next to the relevant keyword in the <strong>Matches for</strong> list.</p>

<p>You can also <b>filter your search results:</b></p>
  <ul class="zero">
    <li><strong>By media type</strong> - will display only objects of a selected media type (images, text, video, sound or 3D). </li>
    <li><strong>By language</strong> - will display only objects with descriptions in selected languages, i.e. the language of the institution that provided the object to Europeana.</li>
    <li><strong>By date</strong> - will display only objects with selected dates.</li>
    <li><strong>By country</strong> - will display only objects from selected countries, i.e. the country of the institution that provided the object to Europeana.</li>
    <li><strong>By copyright</strong> – will display objects labelled with the selected copyright label(s). This copyright label indicates how you may reuse the digital object, including the preview.</li>
    <li><strong>By provider</strong> - will display only objects from selected institutions</li>
  </ul>

<p>Select the filter name, e.g. \'By language\' to expand it. Then just use the check boxes for the categories you wish the search results to include. The results will refresh automatically. The filter will be added to the <strong>Matches for</strong> list at the top of the pane.</p>

<p>To remove a filter, hit the X icon next to the item in the <strong>Matches for</strong> list, or de-select the check box next to the filter category.</p>

<p>You can also select to <strong>Include content contributed by users</strong>. This means items that have not come from a cultural institution but from an individual user, for example, items contributed to the Europeana 1914-1918 project.</p>

<p>Share your search with friends by choosing <b>Share</b>. A full list of social media sharing options is presented. Just select one you want. This also includes print and email options.</p>'
    ).publish!
  end
end

unless Page.find_by_slug('help/explore').present?
  ActiveRecord::Base.transaction do
    Page.create!(
      slug: 'help/explore',
      title: 'Exploring Europeana',
      body: '<p>In addition to the search and filter options, Europeana offers alternative ways to explore and navigate through our millions of objects. You can discover Europe\'s rich heritage by browsing:</p>

  <ul>
    <li><strong>Exhibitions</strong>: Our virtual exhibitions help you discover and learn more about specific themes, e.g. Art Nouveau or musical instruments. With extensive curatorial information that guides you through the themes, the virtual exhibitions can be found by choosing the <strong>Exhibitions</strong> link at the foot of the page.</li>
    <li><strong>New content</strong>: See the latest contributions from our partner museums, libraries, archives and audiovisual archives by choosing <strong>View more latest content from our partners</strong> in the <strong>Featured Partner</strong> area.</li>
  </ul>'
    ).publish!
  end
end

unless Page.find_by_slug('help/results').present?
  ActiveRecord::Base.transaction do
    Page.create!(
      slug: 'help/results',
      title: 'Results in Europeana',
      body: '<p>Europeana divides search results into 5 main categories: text, images, video, sound and 3D objects.</p>
<p>The types of items included in each section are:</p>

<ul class="zero">
<li><strong>Texts</strong>: books, letters, archival papers, dissertations, poems, newspaper articles, facsimiles, manuscripts and music scores.</li>
<li><strong>Images</strong>: paintings, drawings, prints, photographs, pictures of museum objects, maps, graphic designs, plans and musical notation.</li>
<li><strong>Video</strong>: films, news broadcasts and television programmes</li>
<li><strong>Sound</strong>: music and spoken word from cylinders, tapes, discs and radio broadcasts.</li>
<li><strong>3D</strong>: virtual 3D representations of objects, architecture or places.</li>
</ul>

<p>You can also sort search results by media type, language, date, country, copyright, or provider using the Refine your search pane of the results screen. See <strong>Searching Europeana</strong> for more details.</p>

<p>Search results are presented in a grid. You can select how many results to show on a page by selecting an option from the <strong>Results per page</strong> drop-down list either above or below the results. You can select <b>12, 24, 48</b> or <b>96</b>.</p>
<p>To navigate through the results pages, select the single arrows that are shown both above and below the results grid. Hit &gt; or &lt; to move one page in either direction, or hit the double arrows &gt;&gt; or &lt;&lt; to move to the last/first pages. Alternatively, type in the page number of the page you\'d like to view.</p>
<p><strong>Further details</strong> of an object can be found by selecting an item in the results list.</p>

<h2>Individual items</h2>

<p>After performing your search, select the item you want to view to find out more about it.</p>
<p>The item page shows you the following:</p>

  <ul class="zero">
    <li><strong>Thumbnail image/preview</strong> - hit the magnifying glass <strong>View</strong> link at the bottom of the thumbnail to see a bigger image and additional information in a new window. To close that window, hit X at the top right.<br> 
    If there are multiple images of the same object, e.g. pages of a book or different views of an object, a carousel of images is displayed under the main thumbnail. You can select items in the carousel or the left and right arrows on the main thumbnail to browse the images.</li>

<li><strong>Rights and licensing</strong> - below each preview image you will find the rights statement indicating the terms on which you may re-use the digital object, including the preview. There are currently 12 rights statements describing the different terms on which re-use is permitted. Clicking on the rights statement will open a new window with a full description of the terms or, in the case of a Creative Commons licence, a link to the licence itself.</li>

<li><strong>View item at</strong> - view the item on the item provider\'s own website. This is useful, for example, to find additional information and larger images, or to view an item in its fullest form, e.g. a whole book or video.</li>
<li><strong>Share item</strong> - share the item via a range of social media, or to print or email it. Just select the option you want.</li>
<li><strong>Cite on Wikipedia</strong> - this function will help you link to Europeana items and cite them in Wikipedia articles. The code you need is formatted for direct inclusion in Wikipedia\'s article authoring mode. Select <strong>Citation</strong> or <strong>Footnote</strong> and copy and paste the text provided. To close the citation window, hit the X in the top right corner.</li>
<li><strong>Translate details</strong> - select an option from the drop-down list of languages. Please note this is a machine translation.</li>
</ul>

<p>The main area of the item page gives you more information about the item. The amount and type of information will vary but may contain the item\'s name and description along with other information including places, dates, formats, and providers.</p>

<p>This information may contain links to further details. Select these to find the item in an external service, e.g. the data provider\'s own website, or to search Europeana for the highlighted term.</p>

<p>To move to the previous or next item in your search results, hit the <strong>Next</strong> or <strong>Previous</strong> options.</p>

<p>A carousel showing <strong>Similar content</strong> of up to 10 items related to the one you are viewing. Select an image to view more details.</p>

<p>Another way of finding similar content is to use the links in the <strong>Search also for</strong> pane. This provides links to other searches for items with, for example, the same title, author, format or are from the same provider. A number in brackets, e.g. (33) shows the number of results each of these searches returns. Simply hit the link to perform the search.</p>'
    ).publish!
  end
end

error_pages = [
  { title: 'Error', body: "We're sorry! The portal has encountered an error. A report has been automatically sent to the Europeana team to notify us. You can try to reload the page or do another search.", http_code: 500 },
  { title: 'Forbidden', body: 'You do not have permission to access this resource.', http_code: 403 },
  { title: "Sorry, we can't find that page", body: "Unfortunately we couldn't find the page you were looking for. Try searching Europeana or you might like the selected items below.", http_code: 404 },
  { title: 'Bad Request', body: 'There is a problem with your request.', http_code: 400 }
]
error_pages.each do |attrs|
  unless Page::Error.find_by_http_code(attrs[:http_code]).present?
    ActiveRecord::Base.transaction do
      page = Page::Error.create(attrs)
      page.publish!
    end
  end
end
