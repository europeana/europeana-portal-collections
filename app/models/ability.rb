##
# CanCanCan abilities for authorisation
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    meth = user.role.blank? ? :guest! : :"#{user.role}!"
    send(meth) if respond_to?(meth, true) # e.g. admin!
  end

  protected

  def guest!
    can :show, Banner.published
    can :show, Channel.published
    can :show, LandingPage.published
  end

  def user!
    can :show, Banner.published
    can :show, Channel.published
    can :show, LandingPage.published
  end

  def admin!
    can :access, :rails_admin
    can :dashboard
    can :manage, [Banner, BrowseEntry, Channel, HeroImage, LandingPage, Link, MediaObject, User]
  end
end
