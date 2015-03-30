class View < Stache::Mustache::View
  def i18n
    @_translator ||= Translator.new(self)
  end
end
