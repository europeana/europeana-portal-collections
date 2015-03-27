module I18nHelper
  def i18n
    return @_translator unless @_translator.nil?

    # Ignore variables with names like @_internal_use_only
    salient_vars = instance_variables.reject { |name| name.to_s.match(/^@_/) }
    # Gather intance variables
    locals = Hash[salient_vars.map { |name| [name.to_s.sub(/^@/, '').to_sym, instance_variable_get(name)] } ]
    # Ignore variables unless their values are strings or numbers
    locals.reject! { |name, value| !value.is_a?(String) && !value.is_a?(Integer) && !value.is_a?(Fixnum)}

    @_translator = Translator.new(locals)
  end
end
