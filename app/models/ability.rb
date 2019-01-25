# frozen_string_literal: true

##
# CanCanCan abilities for authorisation
class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # guest user (not logged in)

    meth = @user.role.blank? ? :guest! : :"#{@user.role}!"
    send(meth) if respond_to?(meth, true) # e.g. admin!
  end

  def needs_permission?
    return true if @user.role == 'editor'
    false
  end

  protected

  def guest!
    can :show, Banner do |banner|
      banner.published?
    end
    can :show, Collection do |collection|
      collection.published?
    end
    can :show, Gallery do |gallery|
      gallery.published?
    end
    can :show, Page do |page|
      page.published?
    end
  end

  def user!
    guest!
  end

  def editor!
    can :access, :rails_admin
    can :dashboard
    can :show, :entity
    can :read, [Banner, BrowseEntry, Collection, DataProvider, Feed, Gallery,
                HeroImage, Link, MediaObject, Page, Topic, User]
    can :create, [BrowseEntry, Gallery]
    can :update, [DataProvider, HeroImage, MediaObject]
    can :update, BrowseEntry do |entry|
      entry.with_permissions_by?(@user)
    end
    can :publish, BrowseEntry do |entry|
      entry.with_permissions_by?(@user)
    end
    can :unpublish, BrowseEntry do |entry|
      entry.with_permissions_by?(@user)
    end
    can :update, Gallery do |gallery|
      gallery.with_permissions_by?(@user)
    end
    can :publish, Gallery do |gallery|
      gallery.with_permissions_by?(@user)
    end
    can :unpublish, Gallery do |gallery|
      gallery.with_permissions_by?(@user)
    end
    can :update, Page::Landing do |page|
      page.with_permissions_by?(@user)
    end
  end

  def admin!
    can :access, :rails_admin
    can :dashboard
    can :show, :entity
    can :manage, [Banner, BrowseEntry, Collection, DataProvider, Feed, Gallery,
                  HeroImage, Link, MediaObject, Page, Topic, User]
  end
end
