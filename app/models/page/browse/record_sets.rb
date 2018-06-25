# frozen_string_literal: true

class Page
  module Browse
    class RecordSets < Page
      has_many :sets, class_name: 'PageElement::RecordSet', inverse_of: :page,
                      dependent: :destroy
    end
  end
end
