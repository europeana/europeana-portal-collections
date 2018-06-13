# frozen_string_literal: true

module HasPublicationStates
  extend ActiveSupport::Concern

  included do
    include AASM

    enum state: %i(draft published)

    aasm column: :state, enum: true, no_direct_assignment: true do
      state :draft, initial: true
      state :published

      event :publish, after: :after_publish, guard: :publishable? do
        transitions from: :draft, to: :published
      end

      event :unpublish do
        transitions from: :published, to: :draft
      end
    end
  end

  # Callback to run after the publish event has run
  #
  # Override per-model if required
  def after_publish; end

  # Guard for the publish event
  #
  # Override per-model if required
  def publishable?
    true
  end
end
