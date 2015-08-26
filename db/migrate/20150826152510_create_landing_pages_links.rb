class CreateLandingPagesLinks < ActiveRecord::Migration
  def change
    create_join_table :landing_pages, :links do |t|
      t.index :landing_page_id
      t.index :link_id
    end
  end
end
