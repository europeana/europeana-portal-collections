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

  config.included_models = %w(Channel HeroImage LandingPage Link MediaObject User)

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
  end

  config.model 'HeroImage' do
    visible false
    edit do
      field :media_object
      field :license
      group :brand do
        field :brand_circles_opacity, :enum do
          enum do
            HeroImage.brand_circles_opacity_enum.map { |opacity| ["#{opacity}%", opacity] }
          end
        end
        field :brand_circles_position, :enum
        field :brand_circles_colour, :enum
      end
      group :attribution do
        field :attribution_title
        field :attribution_creator
        field :attribution_institution
        field :attribution_url
        field :attribution_text, :text
      end
    end
  end

  config.model 'LandingPage' do
    edit do
      field :channel
      field :credits
      field :hero_image
    end
  end

  config.model 'Link' do
    visible false
    edit do
      field :url, :string
      field :text, :string
    end
  end

  config.model 'MediaObject' do
    visible false
    field :file
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
