# frozen_string_literal: true
class Categorisation < ActiveRecord::Base
  belongs_to :categorisable, polymorphic: true
  belongs_to :topic, inverse_of: :categorisations

  validates :topic_id, presence: true
  validates :categorisable, presence: true

  default_scope { includes(:topic) }

  def topic_name
    topic.name
  end
end
