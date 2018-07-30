# frozen_string_literal: true

RSpec::Matchers.define :have_array_of_strings_attribute do |attribute|
  match do |actual|
    @attribute = attribute
    @getter = :"#{attribute}_text"
    @setter = :"#{attribute}_text="
    @join = "\n\n"
    @split = '  '

    responds_to_setter?(actual) &&
      sets_array_from_text?(actual) &&
      responds_to_getter?(actual) &&
      gets_text_from_array?(actual)
  end

  chain :joining, :join

  chain :splitting, :split

  failure_message do |_actual|
    @failure_message
  end

  def responds_to_setter?(actual)
    return true if actual.respond_to?(@setter)
    @failure_message = "expected #{actual} to respond to #{@setter}"
    false
  end

  def sets_array_from_text?(actual)
    actual.send(@setter, %w(a b).join(split))
    return true if actual.instance_variable_get(:"@#{@attribute}") == %w(a b)
    @failure_message = "expected @#{@attribute} to be array of values"
  end

  def responds_to_getter?(actual)
    return true if actual.respond_to?(@getter)
    @failure_message = "expected #{actual} to respond to #{@getter}"
    false
  end

  def gets_text_from_array?(actual)
    actual.instance_variable_set(:"@#{@attribute}", %w(a b))
    return true if actual.send(@getter) == %w(a b).join(join)
    @failure_message = "expected @#{@attribute} to be array joined to text"
  end
end
