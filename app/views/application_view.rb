##
# A custom class for this project's Mustache templates
#
# Each page-specific view class should sub-class this.
#
# Public methods added to this class will be available to all Mustache
# templates.
class ApplicationView < Europeana::Styleguide::View
  include MustacheHelper

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

  only_call_once :i18n

  protected

  def only_call_once(key)
    @only_call_once ||= {}
    @only_call_once[key] ||= yield
  end
end
