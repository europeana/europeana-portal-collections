module Europeana
  module Blacklight
    class Response
      ##
      # MLT for{Europeana::Blacklight::Response}
      #
      # This will just return blank objects from the MLT methods BL expects.
      module MoreLikeThis
        def more_like(_document)
          []
        end

        def more_like_this
          {}
        end
      end
    end
  end
end
