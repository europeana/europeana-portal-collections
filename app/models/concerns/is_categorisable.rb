# frozen_string_literal: true
module IsCategorisable
  extend ActiveSupport::Concern

  included do
    has_one :categorisation, as: :categorisable
    has_one :topic, through: :categorisation
    accepts_nested_attributes_for :categorisation
  end
end
