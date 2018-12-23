class Address
	attr_accessor :streetAddress
	attr_accessor :city
	attr_accessor :state
	attr_accessor :postalCode

	def initialize(streetAddress, city, state, postalCode)
		@streetAddress = streetAddress
		@city = city
		@state = state
		@postalCode = postalCode
	end
end
