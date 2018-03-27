# frozen_string_literal: true

module HasPublicationStates
  extend ActiveSupport::Concern

  included do
    include AASM

    enum state: %i(draft published)

    aasm column: :state, enum: true, no_direct_assignment: true do
      state :draft, initial: true
      state :published

      event :publish, after: :after_publish do
        transitions from: :draft, to: :published
      end

      event :unpublish do
        transitions from: :published, to: :draft
      end
    end
  end

  ##
  # Override this per-model if required
  def after_publish; end
end
