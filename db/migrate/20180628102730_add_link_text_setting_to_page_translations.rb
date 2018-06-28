# frozen_string_literal: true

class AddLinkTextSettingToPageTranslations < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Page::Browse::RecordSets.add_translation_fields! settings_link_text: :string
      end

      dir.down do
        remove_column :page_translations, :settings_link_text
      end
    end
  end
end
