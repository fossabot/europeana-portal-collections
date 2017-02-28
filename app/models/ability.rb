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
    can :show, Collection.published
    can :show, Gallery.published
    can :show, Page.published
  end

  def user!
    can :show, Banner.published
    can :show, Collection.published
    can :show, Gallery.published
    can :show, Page.published
  end

  def editor!
    can :access, :rails_admin
    can :dashboard
    can :read, [Banner, BrowseEntry, Collection, DataProvider, Gallery,
                HeroImage, Link, MediaObject, Page, Topic, User]
    can :create, [BrowseEntry, Gallery]
    can :update, [BrowseEntry, DataProvider, Gallery,
                  HeroImage, MediaObject, Page::Landing]
  end

  def admin!
    can :access, :rails_admin
    can :dashboard
    can :manage, [Banner, BrowseEntry, Collection, DataProvider, Gallery,
                  HeroImage, Link, MediaObject, Page, Topic, User]
  end
end
