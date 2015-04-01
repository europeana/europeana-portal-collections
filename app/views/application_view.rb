##
# A custom class for this project's Mustache templates
#
# Each of your view classes should sub-class this instead of
# {Stache::Mustache::View}
#
# Public methods added to this class will be available to all Mustache
# templates.
class ApplicationView < Stache::Mustache::View
  ##
  # Performs I18n lookups from within a Mustache template
  # @example Translate the "site.name" key (from within a Mustache template)
  #   {{i18n.site.name}}
  # @return [View::Translator.new]
  def i18n
    @_translator ||= View::Translator.new(context)
  end

  ##
  # Whether or not to enable debugging in Mustache templates
  #
  # Override this in a template-specific view class to enable debugging there.
  #
  # This method is required here to prevent templates hitting the helper
  # method {ActionView::Helpers::DebugHelper#debug} which will raise an
  # {ArgumentError}
  #
  # @return [Boolean]
  def debug
    false
  end
end
