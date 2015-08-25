##
# User model
class User < ActiveRecord::Base
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User # @todo do we need/use this?

  ROLES = %w(user admin)

  # Devise modules.
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
         :validatable

  before_validation do
    self.role = 'user' if role.blank?
  end

  validates :role, inclusion: { in: User::ROLES }

  has_paper_trail

  delegate :can?, :cannot?, to: :ability

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def role_enum
    ROLES
  end

  def ability
    @ability ||= Ability.new(self)
  end
end
