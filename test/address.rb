require 'json'

class Address

	attr_accessor :street_address
	attr_accessor :city
	attr_accessor :state
	attr_accessor :postal_code

	# Using self.from_hash(hash) is usually better, but this code is here in case you prefer this style of constructor
	# def initialize(street_address, city, state, postal_code)
		# @street_address = street_address
		# @city = city
		# @state = state
		# @postal_code = postal_code
	# end

	def self.from_hash(hash)
		o = self.new
		o.street_address = hash[:street_address]
		o.city = hash[:city]
		o.state = hash[:state]
		o.postal_code = hash[:postal_code]
		o
	end

	def self.from_json(json)
		self.from_hash(JSON.parse(json))
	end

	def to_json
		h = {}
		h[:street_address] = @street_address
		h[:city] = @city
		h[:state] = @state
		h[:postal_code] = @postal_code
		JSON.generate(h)
	end
end
