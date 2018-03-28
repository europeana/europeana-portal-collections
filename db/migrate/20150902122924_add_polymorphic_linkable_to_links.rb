# frozen_string_literal: true

class AddPolymorphicLinkableToLinks < ActiveRecord::Migration
  def change
    add_reference :links, :linkable, polymorphic: true, index: true
  end
end
