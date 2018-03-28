# frozen_string_literal: true

class Permission < ActiveRecord::Base
  belongs_to :permissionable, polymorphic: true
  belongs_to :user, inverse_of: :permissions

  default_scope { includes(:permissionable) }
end
