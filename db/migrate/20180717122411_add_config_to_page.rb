# frozen_string_literal: true

class AddConfigToPage < ActiveRecord::Migration
  class Page < ActiveRecord::Base
    self.inheritance_column = nil
    serialize :settings, HashWithIndifferentAccess
    store_accessor :config, :full_width, :layout_type
  end

  def change
    add_column :pages, :config, :jsonb

    reversible do |dir|
      dir.up do
        Page.find_each do |page|
          page.full_width = page.settings['full_width']
          page.save!
        end
        Page.where(type: 'Page::Landing').find_each do |page|
          page.layout_type = page.settings['layout_type']
          page.save!
        end
      end

      dir.down do
        Page.find_each do |page|
          page.settings['full_width'] = page.full_width
          page.save!
        end
        Page.where(type: 'Page::Landing').find_each do |page|
          page.settings['layout_type'] = page.layout_type
          page.save!
        end
      end
    end
  end
end
