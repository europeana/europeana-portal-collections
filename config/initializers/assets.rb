# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Builds a gem version string like ":gem_name-:gem_version(@:gem_git_ref)", e.g.
# "europeana-styleguide-0.3.0@3398ae7"
gem_version = lambda do |gem_name|
  gem_spec = Bundler.environment.dependencies.detect { |d| d.name == gem_name }.to_spec
  "#{gem_name}-#{gem_spec.version}".tap do |version_string|
    version_string << "@#{gem_spec.git_version.strip}" unless gem_spec.git_version.blank?
  end
end

# Changes to certain gems need to invalidate cached assets
%w(europeana-i18n europeana-styleguide).each do |gem_name|
  Rails.application.config.assets.version << '/' if Rails.application.config.assets.version.present?
  Rails.application.config.assets.version << gem_version.call(gem_name)
end

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w(
#   favicon.ico blacklight/logo.png
#   europeana.css blacklight.css
#   search.js jquery.js turbolinks.js
#   blacklight/core.js blacklight/autofocus.js blacklight/checkbox_submit.js blacklight/bookmark_toggle.js
#   blacklight/ajax_modal.js blacklight/search_context.js blacklight/collapsable.js blacklight/blacklight.js
#   bootstrap/transition.js bootstrap/collapse.js bootstrap/dropdown.js bootstrap/alert.js bootstrap/modal.js
# )

# Prevent default behaviour that adds all non-JS/CSS assets
Rails.application.config.assets.precompile.delete(Sprockets::Railtie::LOOSE_APP_ASSETS)

# RailsAdmin assets
Rails.application.config.assets.precompile << lambda do |filename, path|
  path =~ /rails_admin/ && !%w(.js .css).include?(File.extname(filename))
end
Rails.application.config.assets.precompile << lambda do |_filename, path|
  path =~ /(fontawesome-|bootstrap-wysihtml5)/
end
