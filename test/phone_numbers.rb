require 'json'

class PhoneNumbers

	attr_accessor :type
	attr_accessor :number

	# Using self.from_hash(hash) is usually better, but this code is here in case you prefer this style of constructor
	# def initialize(type, number)
		# @type = type
		# @number = number
	# end

	def self.from_hash(hash)
		o = self.new
		o.type = hash[:type]
		o.number = hash[:number]
		o
	end

	def self.from_json(json)
		self.from_hash(JSON.parse(json))
	end

	def to_json
		h = {}
		h[:type] = @type
		h[:number] = @number
		JSON.generate(h)
	end
end
