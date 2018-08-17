# frozen_string_literal: true

##
# Controller methods for redirecting to HTML format if none specified
#
# Include this in a controller so that requests for paths without a format
# extension are redirected to the same with .html appended.
module EnforceDefaultFormat
  extend ActiveSupport::Concern

  class_methods do
    def enforces_default_format(format, **options)
      filter_method = :"redirect_to_#{format}_format"
      define_default_format_enforcement_method(filter_method, format) unless method_defined?(filter_method)
      before_action filter_method, options
    end

    private

    def define_default_format_enforcement_method(method, format)
      define_method(method) do
        return unless params[:format].blank?
        redirect_to url_for(params.merge(format: format))
      end
    end
  end
end
