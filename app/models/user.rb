##
# User model
class User < ActiveRecord::Base
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  ROLES = %w(user admin)

  # Devise modules.
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable

  before_save do
    self.role = 'user' if role.blank?
  end

  validates :role, inclusion: { in: proc { User::ROLES } }

  has_paper_trail

  rails_admin do
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

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def role_enum
    ROLES
  end
end
