# frozen_string_literal: true

class CreateFederationConfig < ActiveRecord::Migration
  def self.up
    create_table :federation_configs do |t|
      t.integer :collection_id, null: false # The ID of the collection this config applies to
      t.string :provider, null: false       # The name of the provider this config applies to
      t.string :context_query               # The default query which should always be applied.
      t.timestamps null: false
    end

    add_index :federation_configs, %i{collection_id provider}
    add_foreign_key :federation_configs, :collections
  end

  def self.down
    drop_table :federation_configs
  end
end
