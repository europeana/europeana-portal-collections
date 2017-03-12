# frozen_string_literal: true
module IsPermissionable
  extend ActiveSupport::Concern

  included do
    has_many :permissions, as: :permissionable, dependent: :destroy
    has_many :users, through: :permissions

    scope :with_permissions_by, ->(user) do
      joins(:permissions).where(permissions: { user_id: user })
    end

    # We need to specify this so that for STI models like Page::Landing
    # the permissionable_type of their base class is used.
    # This is important, as otherwise the permission won't be
    # removable when the delete method is called on user.permissionables,
    # as that "has_many through:" relationship will use reflection and by default
    # this will arrive at the base class only.
    # In order to differntiate between subclasses that are permissionable,
    # a lambda with a where clause on the type can be defined on users.
    def permissionable_type=(class_name)
      super(class_name.constantize.base_class.to_s)
    end

    # Automatically gives permissions to the creator if the creator was an 'editor'
    # can be used as a callback like: "before_create :set_editor_permissions" on the model.
    def set_editor_permissions
      if ::PaperTrail.whodunnit
        creator = User.find(::PaperTrail.whodunnit)
        if creator && creator.role == 'editor'
          self.permissions <<= self.permissions.build(user: creator)
        end
      end
    end
  end
end
