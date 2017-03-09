# frozen_string_literal: true
module Pro
  ##
  # Networks, e.g. authors, from Pro JSON-API.
  class Network < Base
    def self.table_name
      'network'
    end
  end
end
