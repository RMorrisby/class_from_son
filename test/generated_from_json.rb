class Generated_from_json
	attr_accessor :firstName
	attr_accessor :lastName
	attr_accessor :isAlive
	attr_accessor :age
	attr_accessor :address
	attr_accessor :phoneNumbers
	attr_accessor :children
	attr_accessor :spouse

	def initialize(firstName, lastName, isAlive, age, address, phoneNumbers, children, spouse)
		@firstName = firstName
		@lastName = lastName
		@isAlive = isAlive
		@age = age
		@address = address
		@phoneNumbers = phoneNumbers
		@children = children
		@spouse = spouse
	end
end
