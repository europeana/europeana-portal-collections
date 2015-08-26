class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.text :text
      t.text :url
      t.timestamps null: false
    end
  end
end
