# frozen_string_literal: true
class CreateCategorisations < ActiveRecord::Migration
  def change
    create_table :categorisations do |t|
      t.integer :topic_id, index: true
      t.references :categorisable, polymorphic: true
      t.index [:categorisable_type, :categorisable_id], name: :index_categorisations_on_categorisable
      t.timestamps null: false
    end
    add_foreign_key :categorisations, :topics
  end
end
