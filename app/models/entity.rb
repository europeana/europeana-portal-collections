# frozen_string_literal: true
class Entity < ActiveRecord::Base

  attr_reader :type, :namespace, :identifier

  def initialize(type, name, identifier)
    @type = type
    @name = name
    @identifier = identifier
  end
end