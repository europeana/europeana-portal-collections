# frozen_string_literal: true

##
# User model
class User < ActiveRecord::Base
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User # @todo do we need/use this?

  # Devise modules.
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
         :validatable

  has_many :permissions, inverse_of: :user, dependent: :destroy
  has_many :permissionable_landing_pages, -> { where(type: 'Page::Landing') }, class_name: 'Page', through: :permissions,
                                                                               source_type: 'Page', source: :permissionable
  has_many :permissionable_galleries, class_name: 'Gallery', through: :permissions, source_type: 'Gallery',
                                      source: :permissionable
  has_many :permissionable_browse_entries, class_name: 'BrowseEntry', through: :permissions, source_type: 'BrowseEntry',
                                           source: :permissionable

  before_validation do
    self.role = 'user' if role.blank?
  end

  has_paper_trail

  delegate :can?, :cannot?, to: :ability
  delegate :role_enum, to: :class

  has_many :galleries, inverse_of: :publisher, foreign_key: :published_by

  class << self
    def role_enum
      %w(admin editor user)
    end

    def permissionable_landing_page_ids_enum
      Page::Landing.all.map { |permissionable| [permissionable.title, permissionable.id] }
    end

    def permissionable_gallery_ids_enum
      Gallery.all.map { |permissionable| [permissionable.title, permissionable.id] }
    end

    def permissionable_browse_entry_ids_enum
      BrowseEntry.where(type: nil).map { |permissionable| [permissionable.title, permissionable.id] }
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
