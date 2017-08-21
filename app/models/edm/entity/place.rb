class Place
  def initialize(*args)
    @id = args[0]
  end

  def whoami
    "I am a place entity with id=#{@id}"
  end
end
