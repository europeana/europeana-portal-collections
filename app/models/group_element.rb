# frozen_string_literal: true

class GroupElement < ActiveRecord::Base
  belongs_to :element_group, inverse_of: :group_elements, touch: true
  belongs_to :groupable, polymorphic: true
  acts_as_list scope: %i{element_group groupable}
end
