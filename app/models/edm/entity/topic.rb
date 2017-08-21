class Topic
  def initialize(*args)
    @id = args[0]
  end

  def whoami
    "I am a topic entity with id=#{@id}"
  end
end
