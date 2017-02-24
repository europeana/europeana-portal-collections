class CreateJoinTableFeedPage < ActiveRecord::Migration
  def change
    create_join_table :feeds, :pages do |t|
      t.index [:feed_id, :page_id]
      t.index [:page_id, :feed_id]
    end
  end
end
