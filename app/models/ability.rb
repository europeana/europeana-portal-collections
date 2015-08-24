##
# CanCanCan abilities for authorisation
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    unless user.role.blank?
      meth = :"#{user.role}!"
      send(meth) if respond_to?(meth) # e.g. admin!
    end
  end

  def admin!
    can :access, :rails_admin
    can :access, :dashboard
    can :manage, [User]
  end
end
