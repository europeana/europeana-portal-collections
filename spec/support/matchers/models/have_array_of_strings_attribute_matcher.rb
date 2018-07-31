# frozen_string_literal: true

RSpec::Matchers.define :have_array_of_strings_attribute do |attribute|
  match do |actual|
    @attribute = attribute
    @attribute_setter = :"#{attribute}="
    @text_getter = :"#{attribute}_text"
    @text_setter = :"#{attribute}_text="
    @join ||= "\n\n"
    @split ||= '  '
    @array_of_strings ||= %w(a b c)

    responds_to_setter?(actual) &&
      sets_array_from_text?(actual) &&
      responds_to_getter?(actual) &&
      gets_text_from_array?(actual)
  end

  chain :elements, :array_of_strings
  chain :joining, :join
  chain :splitting, :split

  failure_message do |_actual|
    @failure_message
  end

  def responds_to_setter?(actual)
    return true if actual.respond_to?(@text_setter)
    @failure_message = "expected #{actual} to respond to #{@text_setter}"
    false
  end

  def sets_array_from_text?(actual)
    arg = @array_of_strings.join(split)
    actual.send(@text_setter, arg)
    value = actual.send(@attribute)
    return true if value == @array_of_strings
    @failure_message = %<expected #{@text_setter}(#{arg.inspect}) to set attribute "#{@attribute}" to #{@array_of_strings.inspect}, not #{value.inspect}>
    false
  end

  def responds_to_getter?(actual)
    return true if actual.respond_to?(@text_getter)
    @failure_message = "expected #{actual} to respond to #{@text_getter}"
    false
  end

  def gets_text_from_array?(actual)
    string = @array_of_strings.join(join)
    actual.send(@attribute_setter, @array_of_strings)
    value = actual.send(@text_getter)
    return true if value == string
    @failure_message = %(expected #{@text_getter} with attribute "#{@attribute}" == #{@array_of_strings.inspect} to return #{string.inspect}, not #{value.inspect})
    false
  end
end
