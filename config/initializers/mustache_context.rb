require 'mustache/context'

class Mustache
  class Context
    # Let {I18n.translate} query Mustache contexts with {#key?}
    # @see View::Translator
    alias_method :key?, :has_key?
  end
end
