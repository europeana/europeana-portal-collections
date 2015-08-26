##
# User model
class User < ActiveRecord::Base
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User # @todo do we need/use this?

  # Devise modules.
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
         :validatable

  before_validation do
    self.role = 'user' if role.blank?
  end

  has_paper_trail

  delegate :can?, :cannot?, to: :ability
  delegate :role_enum, to: :class

  class << self
    def role_enum
      %w(user admin)
    end
  end

  validates :role, inclusion: { in: role_enum }

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email.present? ? email : super
  end

  def ability
    @ability ||= Ability.new(self)
  end
end
