class Person
  def initialize(*args)
    @id = args[0]
  end

  def whoami
    "I am a person entity with id=#{@id}"
  end
end
