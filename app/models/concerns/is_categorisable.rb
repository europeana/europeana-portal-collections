# frozen_string_literal: true

module IsCategorisable
  extend ActiveSupport::Concern

  included do
    has_many :categorisations, as: :categorisable
    has_many :topics, through: :categorisations
    accepts_nested_attributes_for :categorisations
  end

  def topic_ids_enum
    Topic.all.sort_by(&:label).map { |topic| [topic.label, topic.id] }
  end
end
