# frozen_string_literal: true

require 'rails_admin/config/actions/publish'
require 'rails_admin/config/actions/unpublish'
require 'rails_admin/config/actions/requeue'
require 'rails_admin/config/fields/extensions/generic_help'

RailsAdmin::Config::Fields::Types::Text.send(:include, RailsAdmin::Config::Fields::Extensions::GenericHelp)
RailsAdmin::ApplicationHelper.send(:include, ::I18nHelper)

# Workaround for https://github.com/sferik/rails_admin/issues/2502
RailsAdmin::Config::Fields::Types::Json.inspect # Load before override.
class RailsAdmin::Config::Fields::Types::Json
  def queryable?
    false
  end
end

RailsAdmin::Config.parent_controller = 'ApplicationController'

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
    Banner BrowseEntry Collection DataProvider DataProviderLogo
    Europeana::Record::Set FacetLinkGroup FederationConfig Feed Gallery HeroImage
    Link Link::Promotion Link::Credit Link::SocialMedia MediaObject Page
    Page::Browse::RecordSets Page::Error Page::Landing Topic User
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
    requeue
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
      scopes [:search]
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
      field :api_url
      field :api_params
      field :settings_default_search_layout, :enum
    end
    edit do
      field :key do
        read_only do
          true if bindings[:object].persisted?
        end
      end
      field :title
      field :api_url
      field :api_params, :text do
        html_attributes rows: 15
      end
      field :settings_default_search_layout, :enum
      field :federation_configs
    end
  end

  config.model 'DataProvider' do
    list do
      sort_by :uri
      field :uri
      field :name
      field :image, :paperclip do
        thumb_method :medium
      end
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
      field :image, :paperclip do
        help 'transparent & greyscale'
        thumb_method :medium
      end
    end
  end

  config.model 'DataProviderLogo' do
    visible false
    field :image do
      thumb_method :medium
    end
  end

  config.model 'Europeana::Record::Set' do
    object_label_method :pref_label
    visible false

    edit do
      field :pref_label
      field :position, :hidden
      field :alt_label_text, :text do
        html_attributes rows: 5, cols: 80
      end
      field :portal_urls_text, :text do
        required true
        html_attributes rows: 15, cols: 80
      end
      field :query_term
    end
  end

  config.model 'FacetLinkGroup' do
    object_label_method :facet_field
    visible false
    show do
      field :facet_field
      field :facet_values_count
      field :thumbnails
    end
    edit do
      field :facet_field, :enum
      field :facet_values_count, :integer
      field :thumbnails, :boolean
    end
  end

  config.model 'FederationConfig' do
    object_label_method :provider
    visible false
    edit do
      field :provider, :enum
      field :context_query
    end
  end

  config.model 'Feed' do
    list do
      field :name
      field :slug
      field :url
    end
    show do
      field :name
      field :slug
      field :url
    end
    edit do
      field :name
      field :url
    end
  end

  config.model 'Gallery' do
    list do
      field :title do
        searchable 'gallery_translations.title'
        queryable true
        filterable true
      end
      field :state
      field :image_errors do
        pretty_value do
          if value.present?
            bindings[:view].tag(:span, class: 'icon-warning-sign', title: 'This gallery has image errors!')
          else
            ''
          end
        end
      end
      field :publisher
      field :published_at
    end
    show do
      field :title
      field :description
      field :state
      field :publisher
      field :published_at
    end
    edit do
      field :title
      field :description, :text
      field :topic_ids, :enum do
        multiple true
      end
      field :image_portal_urls_text, :text do
        html_attributes rows: 15, cols: 80
      end
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
      field :license, :enum do
        enum do
          HeroImage.license_enum.map do |hero_license|
            [HeroImage.edm_rights(hero_license).label, hero_license]
          end
        end
      end
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
      field :full_width, :boolean
    end
  end

  config.model 'Page::Browse::RecordSets' do
    object_label_method :title
    list do
      field :slug
      field :title do
        searchable 'page_translations.title'
        queryable true
        filterable true
      end
      field :state
    end
    show do
      field :slug
      field :title
      field :state
    end
    edit do
      field :slug
      field :title
      field :link_text
      field :base_query
      field :set_query
      field :sets
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
      field :collection
      field :slug
      field :title
      field :hero_image_file, :paperclip
      field :state
    end
    show do
      field :collection
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
      field :facet_link_groups
      field :banner
      field :newsletter_url
      field :feeds
    end
    edit do
      field :collection do
        visible do
          true unless bindings[:object].persisted?
        end
        associated_collection_scope do
          proc do |scope|
            scope.published.includes(:landing_page).where(pages: { collection_id: nil })
          end
        end
      end
      field :title
      field :layout_type, :enum
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
      field :facet_link_groups
      field :browse_entries do
        orderable true
        nested_form false
        inline_add false
        associated_collection_scope do
          proc { |_scope| BrowseEntry.search.published }
        end
      end
      field :banner
      field :newsletter_url
      field :feeds
    end
  end

  config.model 'Topic' do
    object_label_method :label
    list do
      field :label do
        searchable 'topic_translations.label'
        queryable true
        filterable true
      end
      field :entity_uri
    end
    show do
      field :label
      field :entity_uri
    end
    edit do
      field :label
      field :entity_uri, :string
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
      group :permissions do
        visible do
          # Checking for persisted here as a new record won't ever have the editor role,
          # unless it was sent back due to validation errors. This keeps the CMS UI consistent.
          true if bindings[:object].role == 'editor' && bindings[:object].persisted?
        end
        field :permissionable_landing_page_ids, :enum do
          multiple true
        end
        field :permissionable_gallery_ids, :enum do
          multiple true
        end
        field :permissionable_browse_entry_ids, :enum do
          multiple true
        end
      end
    end
  end
end
