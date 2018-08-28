# frozen_string_literal: true

class RenameEuropeanaRecordSetTitleToPrefLabel < ActiveRecord::Migration
  class PageTranslation < ActiveRecord::Base; end

  def change
    rename_column(:europeana_record_set_translations, :title, :pref_label)

    reversible do |dir|
      dir.up do
        PageTranslation.where.not('link_text IS NULL').find_each do |translation|
          next unless translation.link_text.present?
          new_link_text = translation.link_text.gsub('%{set_title}', '%{set_pref_label}')
          translation.update_attribute(:link_text, new_link_text)
        end
      end

      dir.down do
        PageTranslation.where.not('link_text IS NULL').find_each do |translation|
          next unless translation.link_text.present?
          new_link_text = translation.link_text.gsub('%{set_pref_label}', '%{set_title}')
          translation.update_attribute(:link_text, new_link_text)
        end
      end
    end
  end
end
