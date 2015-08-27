# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

art_channel = Channel.create(
  key: 'art',
  api_params: '(what: "fine art") OR (what: "beaux arts") OR (what: "bellas artes") OR (what: "belle arti") OR (what: "schone kunsten") OR (what:"konst") OR (what:"bildende kunst") OR (what: decorative arts) OR (what: konsthantverk) OR (what: "arts décoratifs") OR (what: paintings) OR (what: schilderij) OR (what: pintura) OR (what: peinture) OR (what: dipinto) OR (what: malerei) OR (what: måleri) OR (what: målning) OR (what: sculpture) OR (what: skulptur) OR (what: sculptuur) OR (what: beeldhouwwerk) OR (what: drawing) OR (what: poster) OR (what: tapestry) OR (what: jewellery) OR (what: miniature) OR (what: prints) OR (what: träsnitt) OR (what: holzschnitt) OR (what: woodcut) OR (what: lithography) OR (what: chiaroscuro) OR (what: "old master print") OR (what: estampe) OR (what: porcelain) OR (what: Mannerism) OR (what: Rococo) OR (what: Impressionism) OR (what: Expressionism) OR (what: Romanticism) OR (what: "Neo-Classicism") OR (what: "Pre-Raphaelite") OR (what: Symbolism) OR (what: Surrealism) OR (what: Cubism) OR (what: "Art Deco") OR (what: Dadaism) OR (what: "De Stijl") OR (what: "Pop Art") OR (what: "art nouveau") OR (what: "art history") OR (what: "http://vocab.getty.edu/aat/300041273") OR (what: "histoire de l\'art") OR (what: (art histoire)) OR (what: kunstgeschichte) OR (what: "estudio de la historia del arte") OR (what: Kunstgeschiedenis) OR (what: "illuminated manuscript") OR (what: buchmalerei) OR (what: enluminure) OR (what: "manuscrito illustrado") OR (what: "manoscritto miniato") OR (what: boekverluchting) OR (what: exlibris) OR (europeana_collectionName: "91631_Ag_SE_SwedishNationalHeritage_shm_art") OR (DATA_PROVIDER: "Institut für Realienkunde") OR (DATA_PROVIDER: "Bibliothèque municipale de Lyon") OR (DATA_PROVIDER:"Museu Nacional d\'Art de Catalunya") OR (DATA_PROVIDER:"Victoria \and Albert Museum") OR (PROVIDER:Ville+de+Bourg-en-Bresse) NOT (what: "printed serial" OR what:"printedbook" OR "printing paper" OR "printed music" OR DATA_PROVIDER:"NALIS Foundation" OR PROVIDER:"OpenUp!" OR PROVIDER:"BHL Europe" OR PROVIDER:"EFG - The European Film Gateway" OR DATA_PROVIDER: "Malta Aviation Museum Foundation")'
)


Channel.create(
  key: 'archaeology',
  api_params: '(what: archaeology) OR (what: archäologie) OR (what: Altertümerkunde)
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
)

Channel.create(
  key: 'architecture',
  api_params: '(what: architecture) OR (what: arkitektur) OR (what: architektur) OR
  (what: buildings) OR (what: ruin) OR DATA_PROVIDER: "Architekturmuseum der
  Technischen Universität Berlin in der Universitätsbibliothek" OR
  DATA_PROVIDER: "Nederlands Architectuurinstituut" OR DATA_PROVIDER:
  "The National Architectural Heritage Board" OR DATA_PROVIDER:
  "Vereniging De Hollandsche Molen"'
)

Channel.create(
  key: 'fashion',
  api_params: '(PROVIDER: "Europeana Fashion") OR (what: Fashion) OR (what: mode) OR (what: moda) OR (what: costume) OR (what: clothes) OR (what: shoes) OR (what: jewellery)'
)

Channel.create(
  key: 'home',
  api_params: '*:*'
)

Channel.create(
  key: 'maps',
  api_params: 'what:maps OR what:cartography OR what:kartografi OR what:cartographic OR what:geography OR what:geografi OR what:navigation OR what:chart OR what: portolan OR what: "mappa mundi" OR what: cosmography OR what:kosmografi OR what: "astronomical instrument" OR what:"celestial globe" OR title:cosmographia OR title:geographia OR title:geographica OR what:"aerial photograph" OR what:periplus OR what:atlas OR what:"armillary sphere" OR what:"terrestrial globe" OR what:"jordglob" OR what:globus NOT (PROVIDER:"OpenUp!")'
)

ActiveRecord::Base.transaction do
  music_channel = Channel.create(
    key: 'music',
    api_params: 'qf=(PROVIDER:"Europeana Sounds" AND (what:music)) OR (PROVIDER:"DISMARC") OR (PROVIDER: "MIMO - Musical Instrument Museums Online") OR ((what:music OR "performing arts") AND (DATA_PROVIDER:"Netherlands Institute for Sound and Vision")) OR ((what:music) AND (DATA_PROVIDER:"Open Beelden")) OR ((what:musique OR title:musique) AND (DATA_PROVIDER:"National Library of France")) OR ((what:musique OR title:musique) AND (DATA_PROVIDER:"The British Library"))&reusability=open&reusability=restricted'
  )
  music_hero_media_url = 'http://styleguide.europeana.eu/images/sample/channel_hero_music.jpg'
  url_hash = MediaObject.hash_source_url(music_hero_media_url)
  media_object = MediaObject.find_or_initialize_by(source_url_hash: url_hash)
  if media_object.new_record?
    media_object.source_url = music_hero_media_url
    DownloadRemoteMediaObjectJob.perform_later(music_hero_media_url)
  end
  music_hero = HeroImage.create(
    attribution_title: 'Danse de trois faunes et trois bacchantes',
    attribution_creator: 'Hieronymus Hopfer',
    attribution_institution: 'Bibliothèque municipale de Lyon',
    attribution_url: '/portal/record/15802/eDipRouteurBML_eDipRouteurBML_aspx_Application_ESTA_26Action_RechercherDirectement_NUID___554__ESTA_3BAfficherVueSurEnregistrement_Vue_Fiche_Principal_3BAfficherFrameset.html',
    license: 'public',
    media_object: media_object
  )
  music_landing = LandingPage.create(
    channel: music_channel,
    credits: [
      Link.new(url: 'http://www.europeanasounds.eu/', text: 'Europeana Sounds')
    ],
    hero_image: music_hero
  )
end

Channel.create(
  key: 'natural-history',
  api_params: '(what: natural history) OR ("histoire naturelle") OR (naturgeschichte) OR ("historia naturalna") OR ("historia natural") OR (what: biology) OR (what: geology) OR (what: zoology) OR (what:entomology) OR (what:ornithology) OR (what:mycology) OR (what: specimen) OR (what: fossil) OR (what:animal) OR (what:flower) OR (what:palaeontology) OR (what:paleontology) OR (what:flora) OR (what:fauna) OR ((title:fauna AND TYPE:TEXT)) OR ((title:flora AND TYPE:TEXT)) OR (what:evolution) OR (what:systematics) OR (what:systematik) OR (what:plant) OR (what:insect) OR (what:insekt) OR (herbarium) OR (carl linnaeus) OR (Carl von Linné) OR (Leonhart Fuchs) OR (Otto Brunfels) OR (Hieronymus Bock) OR (Valerius Cordus) OR (Konrad Gesner) OR (Frederik Ruysch) OR (Gaspard Bauhin) OR (Henry Walter Bates) OR (Charles Darwin) OR (Alfred Russel Wallace) OR (Georges Buffon) OR (Jean-Baptiste de Lamarck) OR (Maria Sibylla Merian) OR (naturalist) OR (de materia media) OR (historiae animalium) OR (systema naturae) OR (botanica) OR (plantarum) OR (PROVIDER:"OpenUp!") OR (PROVIDER:"STERNA") OR (PROVIDER:"The Natural Europe Project") OR (PROVIDER:"BHL Europe") NOT (DATA_PROVIDER:"askabaoutireland.ie")'
)

Channel.create(
  key: 'newspapers',
  api_params: 'what:newspapers'
)

Channel.create(
  key: 'performing-arts',
  api_params: '(what: "performance art") OR (what: "performing arts") OR (what:
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
)
