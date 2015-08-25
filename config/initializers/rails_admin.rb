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
