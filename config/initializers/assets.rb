# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( favicon.ico blacklight/logo.png )
Rails.application.config.assets.precompile += %w( europeana.css blacklight.css )
Rails.application.config.assets.precompile += %w( jquery.js turbolinks.js )
Rails.application.config.assets.precompile += %w( blacklight/core.js blacklight/autofocus.js blacklight/checkbox_submit.js blacklight/bookmark_toggle.js blacklight/ajax_modal.js blacklight/search_context.js blacklight/collapsable.js blacklight/blacklight.js )
Rails.application.config.assets.precompile += %w( bootstrap/transition.js bootstrap/collapse.js bootstrap/dropdown.js bootstrap/alert.js bootstrap/modal.js )
