##
# A custom class for this project's Mustache templates
#
# Each of your view classes should sub-class this instead of
# {Stache::Mustache::View}
#
# Public methods added to this class will be available to all Mustache
# templates.
class ApplicationView < Stache::Mustache::View
  class << self
    attr_accessor :only_call_once_aliases

    def only_call_once(*methods)
      @only_call_once_aliases ||= {}
      methods.flatten.each do |meth|
        meth_alias = "only_call_once_#{meth}".to_sym
        next if respond_to?(meth_alias)
        alias_method meth_alias, meth
        @only_call_once_aliases[meth] = meth_alias
        define_method(meth) do
          only_call_once(meth) do
            send(meth_alias.to_sym)
          end
        end
      end
    end
  end

  def initialize
    self.class.only_call_once_aliases ||= {}
    methods = self.class.instance_methods(false)
    methods.select! { |meth| self.method(meth).arity == 0 }
    methods.reject! { |meth| self.class.only_call_once_aliases.values.include?(meth) }
    methods.reject! { |meth| self.class.only_call_once_aliases.keys.include?(meth) }
    self.class.send(:only_call_once, methods)
  end

  ##
  # Performs I18n lookups from within a Mustache template
  # @example Translate the "site.name" key (from within a Mustache template)
  #   {{i18n.site.name}}
  # @return [View::Translator.new]
  def i18n
    View::Translator.new(context)
  end
  only_call_once :i18n

  ##
  # Whether or not to enable debugging in Mustache templates
  #
  # Override this in a template-specific view class to enable debugging there.
  # The overriden method should return the textual debug output.
  #
  # This method is required here to prevent templates hitting the helper
  # method {ActionView::Helpers::DebugHelper#debug} which will raise an
  # {ArgumentError}
  #
  # @return [Boolean]
  def debug
    false
  end

  def only_call_once(key)
    @only_call_once ||= {}
    @only_call_once[key] ||= yield
  end
end
