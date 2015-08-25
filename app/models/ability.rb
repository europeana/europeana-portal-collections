##
# CanCanCan abilities for authorisation
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    unless user.role.blank?
      meth = :"#{user.role}!"
      send(meth) if respond_to?(meth, true) # e.g. admin!
    end
  end

  protected

  def admin!
    can :access, :rails_admin
    can :dashboard
    can :manage, [Channel, User]
  end
end
