class Stache::Mustache::View
  def method_missing(method, *args, &block)
    if view_method_arity_matches?(method, *args)
      view.send(method, *args, &block)
    else
      super
    end
  end

  protected

  ##
  # Do a crude sanity check on number of parameters for method delegation to view
  def view_method_arity_matches?(method, *args)
    @_view_methods_arity ||= {}
    if @_view_methods_arity.key?(method) && @_view_methods_arity[method].key?(args.size)
      return @_view_methods_arity[method][args.size]
    end
    @_view_methods_arity[method] ||= {}

    return false unless view.respond_to?(method, true)

    view_method_parameters = view.method(method).parameters
    req_parameters = view_method_parameters.select { |p| p.first == :req }
    opt_parameters = view_method_parameters.select { |p| p.first == :opt }
    rest_parameters = view_method_parameters.select { |p| p.first == :rest }

    res = if args.size < req_parameters.size
            false
          elsif rest_parameters.blank? && args.size > (req_parameters.size + opt_parameters.size)
            false
          else
            true
          end

    @_view_methods_arity[method][args.size] = res
  end
end
