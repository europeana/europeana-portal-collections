# frozen_string_literal: true

class RenameFirstWorldWarTopic < ActiveRecord::Migration
  def up
    if topic = Topic.find_by_slug('first-world-war')
      topic.label = 'World War I'
      topic.slug = 'world-war-i'
      topic.save
    end
  end

  def down
    if topic = Topic.find_by_slug('world-war-i')
      topic.label = 'First World War'
      topic.slug = 'first-world-war'
      topic.save
    end
  end
end
