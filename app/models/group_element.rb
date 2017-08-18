class GroupElement < ActiveRecord::Base
  belongs_to :group, inverse_of: :elements, touch: true
  belongs_to :positionable, polymorphic: true
  acts_as_list scope: [:group, :positionable]
end
