# frozen_string_literal: true

class AddNewsletterUrlToPage < ActiveRecord::Migration
  def change
    add_column :pages, :newsletter_url, :string

    reversible do |dir|
      dir.up do
        if fashion = Page::Landing.find_by_slug('collections/fashion')
          fashion.update_attributes(newsletter_url: 'http://europeanafashion.us5.list-manage.com/subscribe?u=08acbb4918e78ab1b8b1cb158&id=eeaec60e70')
        end
      end
    end
  end
end
