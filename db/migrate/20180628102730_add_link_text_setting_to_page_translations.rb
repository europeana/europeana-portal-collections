# frozen_string_literal: true

class AddLinkTextSettingToPageTranslations < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Page.add_translation_fields! link_text: :string
      end

      dir.down do
        remove_column :page_translations, :link_text
      end
    end
  end
end
