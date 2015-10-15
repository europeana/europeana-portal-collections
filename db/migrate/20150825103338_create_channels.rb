class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :key
      t.text :api_params

      t.timestamps null: false
    end
  end
end
