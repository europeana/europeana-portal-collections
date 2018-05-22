# frozen_string_literal: true

# Model concern adding a DSL for conditional model validation: may validate; may not!
#
# Useful when responsibility for deciding whether or not certain validations run
# needs to lie outside of the model, e.g. in a controller or background job.
#
# @example
#   class Document
#     include ActiveModel::Validations
#     include MayValidateMayNot
#
#     may_validate_with :caution
#     validates :email, presence: true, if: :validating_with_caution?
#   end
#
#   doc = Document.new
#   doc.valid? #=> true
#   doc.validating_with(:caution) do
#     doc.valid?
#   end #=> false
module MayValidateMayNot
  extend ActiveSupport::Concern

  class_methods do
    def may_validate_with(*switches)
      validation_switches.push(*switches)

      switches.each do |switch|
        define_method "validating_with_#{switch}?" do
          @validating_with.include?(switch)
        end
      end
    end

    def validation_switches
      @validation_switches ||= []
    end
  end

  included do
    after_initialize do
      @validating_with = []
    end
  end

  def validating_with?(switch)
    @validating_with.include?(switch)
  end

  def validating_with(*switches)
    unknown_switches = switches - self.class.validation_switches
    unless unknown_switches.blank?
      fail ArgumentError, "Unknown validation switches: #{unknown_switches.join(', ')}"
    end

    @validating_with.push(*switches)

    result = yield

    @validating_with -= switches

    result
  end
end
