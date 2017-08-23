# frozen_string_literal: true

module EDM
  module Entity
    class Agent < EDM::Entity::Base
      has_human_type 'person'
    end
  end
end
