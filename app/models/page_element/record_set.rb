# frozen_string_literal: true

class PageElement
  # A page element consisting of a set of Europeana records
  #
  # TODO: store on the Sets API once implemented?
  class RecordSet < ActiveRecord::Base
    belongs_to :page, class_name: 'Page::Browse::RecordSets', inverse_of: :sets
    validates :page, presence: true
    validates :europeana_ids, presence: true
    validates :title, presence: true, uniqueness: { scope: :page_id }
  end
end
