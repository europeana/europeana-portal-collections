module HasPublicationStates
  extend ActiveSupport::Concern

  included do
    include AASM

    enum state: [:draft, :published]

    aasm column: :state, enum: true, no_direct_assignment: true do
      state :draft, initial: true
      state :published

      event :publish do
        transitions from: :draft, to: :published
      end

      event :unpublish do
        transitions from: :published, to: :draft
      end
    end
  end
end
