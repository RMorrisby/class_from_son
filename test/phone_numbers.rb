require 'json'

class PhoneNumbers

  attr_accessor :type
  attr_accessor :number

  # Using self.from_hash(hash) is usually better, but this code is here in case you prefer this style of constructor
  # def initialize(type, number)
    # @type = type
    # @number = number
  # end

  def self.from_hash(h)
    o = self.new
    o.type = h[:type]
    o.number = h[:number]
    o
  end

  def self.from_json(json)
    self.from_hash(JSON.parse(json, :symbolize_names => true))
  end

  def to_hash
    h = {}
    h[:type] = @type
    h[:number] = @number
    h
  end

  def to_json
    JSON.generate(to_hash)
  end
  alias to_s to_json
end
