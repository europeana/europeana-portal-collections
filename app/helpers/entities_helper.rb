# frozen_string_literal: true

##
# Entities helpers
#
module EntitiesHelper
  # Capitalize all words in sentence
  def capitalize_words(sentence)
    sentence.split.map(&:capitalize).join(' ')
  end
end
