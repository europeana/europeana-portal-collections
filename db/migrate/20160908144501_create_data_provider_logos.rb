# frozen_string_literal: true

class CreateDataProviderLogos < ActiveRecord::Migration
  def change
    create_table :data_provider_logos do |t|
      t.belongs_to :data_provider, index: true

      t.timestamps null: false
    end
  end
end
