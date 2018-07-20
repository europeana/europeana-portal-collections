class AddConfigToPage < ActiveRecord::Migration
  def change
    add_column :pages, :config, :jsonb

    reversible do |dir|
      Page.send(:serialize, :settings, HashWithIndifferentAccess)

      dir.up do
        Page.find_each do |page|
          page.full_width = page.settings['full_width']
          page.save!(validate: false)
        end
        Page::Landing.find_each do |page|
          page.layout_type = page.settings['layout_type']
          page.save!(validate: false)
        end
      end

      dir.down do
        Page.find_each do |page|
          page.settings['full_width'] = page.full_width
          page.save!(validate: false)
        end
        Page::Landing.find_each do |page|
          page.settings['layout_type'] = page.layout_type
          page.save!(validate: false)
        end
      end
    end
  end
end
