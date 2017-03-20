# frozen_string_literal: true
module Pro
  ##
  # Persons from Pro JSON-API.
  class Person < Base
    def self.table_name
      'persons'
    end
  end
end
