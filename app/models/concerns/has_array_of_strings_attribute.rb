# frozen_string_literal: true

# Module for working with model attributes that are arrays of strings
#
# @example Getting and setting as text
#   class MyDocument
#     include HasArrayOfStringsAttribute
#     attr_accessor :tags
#     has_array_of_strings_attribute :tags, join: ', ', split: ','
#   end
#
#   doc = MyDocument.new
#   doc.tags = %w(jazz saxophone)
#   doc.tags_text #=> "jazz, saxophone"
#   doc.tags_text = "jazz,saxophone,vocal"
#   doc.tags #=> ["jazz", "saxophone", "vocal"]
module HasArrayOfStringsAttribute
  extend ActiveSupport::Concern

  class_methods do
    # Get & set array of strings attribute(s) as text
    #
    # @param attributes [Symbol] Attribute(s) to define text-based getter/setter for
    # @param join [String] Separator to join array of strings with when calling getter
    # @param split [String,Regexp] Separator to split text by when calling setter
    def has_array_of_strings_attribute(*attributes, join: "\n\n", split: /\s+/)
      attributes.each do |attribute|
        define_method("#{attribute}_text") do
          send(attribute)&.join(join)
        end

        define_method("#{attribute}_text=") do |string|
          array = string&.split(split)
          send(:"#{attribute}=", array)
        end
      end
    end
  end
end
