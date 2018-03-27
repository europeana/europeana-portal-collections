# frozen_string_literal: true

class AddStraplineToPages < ActiveRecord::Migration
  def up
    add_column :pages, :strapline, :string
    Page.add_translation_fields! strapline: :string
  end

  def down
    remove_column :page_translations, :strapline
    remove_column :pages, :strapline
  end
end
