require 'rails_admin/config/actions/publish'
require 'rails_admin/config/actions/unpublish'

RailsAdmin.config do |config|
  # Devise
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # Cancan
  config.authorize_with :cancan

  # PaperTrail
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version'

  config.included_models = %w(
    Banner Banner::Translation BrowseEntry BrowseEntry::Translation Collection HeroImage
    Link Link::Translation Link::Promotion Link::Credit Link::SocialMedia MediaObject Page
    Page::Error Page::Landing Page::Translation User
  )

  config.actions do
    dashboard
    index
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
    history_index
    history_show
    publish
    unpublish
  end

  config.model 'Banner' do
    visible true
    configure :translations, :globalize_tabs
    list do
      field :title
      field :state
      field :default
    end
    show do
      field :title
      field :state
      field :body
      field :default
      group :link do
        field :link_url
        field :link_text
      end
    end
    edit do
      field :translations
      field :default do
        help 'Only one, published, banner can be the default.'
      end
      field :link
    end
  end

  config.model 'Banner::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :title, :body
  end

  config.model 'BrowseEntry' do
    visible false
    configure :translations, :globalize_tabs
    edit do
      field :translations
      field :position
      field :query
      field :file, :paperclip
      field :settings_category, :enum
    end
  end

  config.model 'BrowseEntry::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :title
  end

  config.model 'Collection' do
    list do
      sort_by :key
      field :key
      field :state
    end
    show do
      field :key
      field :state
      field :api_params
    end
    edit do
      field :key
      field :api_params
    end
  end

  config.model 'HeroImage' do
    visible false
    list do
      field :media_object
      field :license
    end
    show do
      field :file, :paperclip do
        thumb_method :medium
      end
      field :license
      group :brand do
        field :settings_brand_opacity, :enum do
          enum do
            HeroImage.settings_brand_opacity_enum.map { |opacity| ["#{opacity}%", opacity] }
          end
        end
        field :settings_brand_position, :enum
        field :settings_brand_colour, :enum
      end
      group :attribution do
        field :settings_attribution_title
        field :settings_attribution_creator
        field :settings_attribution_institution
        field :settings_attribution_url
        field :settings_attribution_text, :text
      end
    end
    edit do
      field :file, :paperclip
      field :license
      group :brand do
        field :settings_brand_opacity, :enum do
          enum do
            HeroImage.settings_brand_opacity_enum.map { |opacity| ["#{opacity}%", opacity] }
          end
        end
        field :settings_brand_position, :enum
        field :settings_brand_colour, :enum
      end
      group :attribution do
        field :settings_attribution_title
        field :settings_attribution_creator
        field :settings_attribution_institution
        field :settings_attribution_url
        field :settings_attribution_text, :text
      end
    end
  end

  config.model 'Link' do
    object_label_method :text
    visible false
    configure :translations, :globalize_tabs
    edit do
      field :url, :string
      field :translations
    end
  end

  config.model 'Link::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :text
  end

  config.model 'Link::Promotion' do
    object_label_method :text
    visible false
    configure :translations, :globalize_tabs
    edit do
      field :url, :string
      field :translations
      field :position
      field :settings_category, :enum
      field :settings_wide, :boolean
      field :settings_class, :string
      field :file, :paperclip
    end
  end

  config.model 'Link::SocialMedia' do
    object_label_method :text
    visible false
    configure :translations, :globalize_tabs
    edit do
      field :url, :string
      field :translations
    end
  end

  config.model 'Link::Credit' do
    object_label_method :text
    visible false
    configure :translations, :globalize_tabs
    edit do
      field :url, :string
      field :translations
    end
  end

  config.model 'MediaObject' do
    visible false
    field :file do
      thumb_method :medium
    end
  end

  config.model 'Page' do
    object_label_method :title
    configure :translations, :globalize_tabs
    list do
      field :slug
      field :title
      field :hero_image_file, :paperclip
      field :state
      scopes [:static]
    end
    show do
      field :slug
      field :title
      field :hero_image_file, :paperclip
      field :body
      field :state
      field :browse_entries
      field :banner
    end
    edit do
      field :slug
      field :translations
      field :hero_image
      field :browse_entries
      field :banner
    end
  end

  config.model 'Page::Error' do
    object_label_method :title
    configure :translations, :globalize_tabs
    list do
      field :slug
      field :http_code
      field :title
      field :hero_image_file, :paperclip
      field :state
    end
    show do
      field :slug
      field :http_code
      field :title
      field :hero_image_file, :paperclip
      field :body
      field :state
      field :browse_entries
      field :banner
    end
    edit do
      field :slug
      field :http_code
      field :translations
      field :hero_image
      field :browse_entries
      field :banner
    end
  end

  config.model 'Page::Landing' do
    object_label_method :title
    configure :translations, :globalize_tabs
    list do
      field :slug
      field :title
      field :hero_image_file, :paperclip
      field :state
    end
    show do
      field :slug
      field :title
      field :hero_image_file, :paperclip
      field :state
      field :credits
      field :social_media
      field :promotions
      field :browse_entries
      field :banner
    end
    edit do
      field :slug
      field :translations
      field :hero_image
      field :credits
      field :social_media
      field :promotions
      field :browse_entries
      field :banner
    end
  end

  config.model 'Page::Translation' do
    visible false
    configure :locale, :hidden do
      help ''
    end
    include_fields :locale, :title, :body
    edit do
      field :title
      field :body, :text do
        html_attributes rows: 15, cols: 80
      end
    end
  end

  config.model 'User' do
    object_label_method :email
    list do
      field :email
      field :guest
      field :role
      field :current_sign_in_at
    end
    edit do
      field :email
      field :password
      field :password_confirmation
      field :role
    end
  end
end
