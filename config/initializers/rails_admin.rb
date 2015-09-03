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

  config.included_models = %w(Channel HeroImage LandingPage Link Link::Promotion Link::Credit Link::SocialMedia MediaObject Promotion User)

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
  end

  config.model 'Channel' do
    object_label_method :title
    list do
      field :key
      field :title
    end
    edit do
      field :key
      field :title
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

  config.model 'LandingPage' do
    list do
      field :channel
      field :hero_image_file, :paperclip
    end
    show do
      field :channel
      field :hero_image_file, :paperclip
      field :credits
      field :social_media
      field :promotions
    end
    edit do
      field :channel
      field :hero_image
      field :credits
      field :social_media
      field :promotions
    end
  end

  config.model 'Link' do
    visible false
    edit do
      field :url, :string
      field :text, :string
    end
  end

  config.model 'Link::Promotion' do
    visible false
    edit do
      field :url, :string
      field :text, :string
      field :position
      field :settings_category, :enum
      field :settings_wide, :boolean
      field :settings_class, :string
      field :file, :paperclip
    end
  end

  config.model 'Link::SocialMedia' do
    visible false
    edit do
      field :url, :string
      field :text, :string
    end
  end

  config.model 'Link::Credit' do
    visible false
    edit do
      field :url, :string
      field :text, :string
    end
  end

  config.model 'MediaObject' do
    visible false
    field :file do
      thumb_method :medium
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
