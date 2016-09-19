require 'rails_admin/config/actions/publish'
require 'rails_admin/config/actions/unpublish'

RailsAdmin.config do |config|
  config.main_app_name = ['Europeana Collections']

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
    Banner BrowseEntry Collection DataProvider DataProviderLogo HeroImage Link
    Link::Promotion Link::Credit Link::SocialMedia MediaObject Page Page::Error
    Page::Landing User
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
    list do
      field :title do
        searchable 'banner_translations.title'
        queryable true
        filterable true
      end
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
      field :title
      field :body, :text do
        html_attributes { { rows: 8, cols: 60 } }
      end
      field :default do
        help 'Only one, published, banner can be the default.'
      end
      field :link
    end
  end

  config.model 'BrowseEntry' do
    list do
      field :title do
        searchable 'browse_entry_translations.title'
        queryable true
        filterable true
      end
      field :file, :paperclip
      field :subject_type
      field :state
    end
    show do
      field :title
      field :query
      field :file, :paperclip do
        thumb_method :medium
      end
      field :subject_type
      field :state
      field :collections
    end
    edit do
      field :title
      field :query
      field :file, :paperclip
      field :subject_type
      field :collections do
        inline_add false
      end
    end
  end

  config.model 'Collection' do
    object_label_method :key
    list do
      sort_by :key
      field :key
      field :title do
        searchable 'collection_translations.title'
        queryable true
        filterable true
      end
      field :state
    end
    show do
      field :key
      field :title
      field :state
      field :api_params
      field :settings_default_search_layout, :enum
    end
    edit do
      field :key
      field :title
      field :api_params
      field :settings_default_search_layout, :enum
    end
  end

  config.model 'DataProvider' do
    list do
      sort_by :uri
      field :uri
      field :name
      field :image, :paperclip
    end
    show do
      field :uri
      field :name
      field :image, :paperclip do
        thumb_method :medium
      end
    end
    edit do
      field :uri
      field :name
      field :image, :paperclip
    end
  end

  config.model 'DataProviderLogo' do
    visible false
    field :image do
      thumb_method :medium
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
        field :settings_ripple_width, :enum
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
        field :settings_brand_colour, :enum
        field :settings_ripple_width, :enum
      end
      group :attribution do
        field :settings_attribution_title
        field :settings_attribution_creator
        field :settings_attribution_institution
        field :settings_attribution_url
      end
    end
  end

  config.model 'Link' do
    object_label_method :text
    visible false
    edit do
      field :url, :string
      field :text
    end
  end

  config.model 'Link::Promotion' do
    object_label_method :text
    visible false
    edit do
      field :url, :string
      field :text
      field :position do
        help 'Items with lower positions appear first.'
      end
      field :settings_category, :enum
      field :settings_wide, :boolean
      field :settings_class, :string
      field :file, :paperclip
    end
  end

  config.model 'Link::SocialMedia' do
    object_label_method :text
    visible false
    edit do
      field :url, :string
      field :text
    end
  end

  config.model 'Link::Credit' do
    object_label_method :text
    visible false
    edit do
      field :url, :string
      field :text
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
    list do
      field :slug
      field :title do
        searchable 'page_translations.title'
        queryable true
        filterable true
      end
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
      field :title
      field :body, :text do
        html_attributes rows: 15, cols: 80
      end
      field :hero_image
      field :browse_entries do
        orderable true
        nested_form false
      end
      field :banner
      field :settings_full_width, :boolean
    end
  end

  config.model 'Page::Error' do
    object_label_method :title
    list do
      field :slug
      field :http_code
      field :title do
        searchable 'page_translations.title'
        queryable true
        filterable true
      end
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
      field :title
      field :body, :text do
        html_attributes rows: 15, cols: 80
      end
      field :hero_image
      field :browse_entries do
        orderable true
        nested_form false
      end
      field :banner
    end
  end

  config.model 'Page::Landing' do
    object_label_method :title
    list do
      field :slug
      field :title
      field :hero_image_file, :paperclip
      field :state
    end
    show do
      field :slug
      field :title do
        searchable 'page_translations.title'
        queryable true
        filterable true
      end
      field :hero_image_file, :paperclip
      field :strapline
      field :state
      field :credits
      field :social_media
      field :promotions
      field :browse_entries
      field :banner
    end
    edit do
      field :slug
      field :title
      field :body, :text do
        html_attributes rows: 15, cols: 80
      end
      field :hero_image
      field :strapline, :text do
        html_attributes rows: 15, cols: 80
      end
      field :credits
      field :social_media
      field :promotions
      field :browse_entries do
        orderable true
        nested_form false
        inline_add false
        associated_collection_scope do
          Proc.new { |_scope| BrowseEntry.published }
        end
      end
      field :banner
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
