class Period
  def initialize(*args)
    @id = args[0]
  end

  def whoami
    "I am a period entity with id=#{@id}"
  end
end
