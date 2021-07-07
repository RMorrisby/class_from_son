require 'json'

class Generated_from_json

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :is_alive
  attr_accessor :age
  attr_accessor :address
  attr_accessor :phone_numbers
  attr_accessor :children
  attr_accessor :spouse

  # Using self.from_hash(hash) is usually better, but this code is here in case you prefer this style of constructor
  # def initialize(first_name, last_name, is_alive, age, address, phone_numbers, children, spouse)
    # @first_name = first_name
    # @last_name = last_name
    # @is_alive = is_alive
    # @age = age
    # @address = address
    # @phone_numbers = phone_numbers
    # @children = children
    # @spouse = spouse
  # end

  def self.from_hash(h)
    o = self.new
    o.first_name = h[:first_name]
    o.last_name = h[:last_name]
    o.is_alive = h[:is_alive]
    o.age = h[:age]
    o.address = h[:address]
    o.phone_numbers = h[:phone_numbers]
    o.children = h[:children]
    o.spouse = h[:spouse]
    o
  end

  def self.from_json(json)
    self.from_hash(JSON.parse(json, :symbolize_names => true))
  end

  def to_hash
    h = {}
    h[:first_name] = @first_name
    h[:last_name] = @last_name
    h[:is_alive] = @is_alive
    h[:age] = @age
    h[:address] = @address
    h[:phone_numbers] = @phone_numbers
    h[:children] = @children
    h[:spouse] = @spouse
    h
  end

  def to_json
    JSON.generate(to_hash)
  end
  alias to_s to_json
end
