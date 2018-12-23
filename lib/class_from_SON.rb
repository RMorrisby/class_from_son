require "json"
require "more-ruby"

# A utility to convert an input file of string-object notation, e.g. JSON, XML, YAML, and generate code that looks like a class of your desired language

class ClassFromSON

	@@target_languages = [:java, :ruby]
	@@input_modes = [:json]

	def error(message)
		puts "ERROR : #{message}"
	end

	def error_and_exit(message)
		puts "ERROR : #{message}"
		exit
	end

	def self.error_and_exit(message)
		puts "ERROR : #{message}"
		exit
	end

	def warn(message)
		puts "WARN : #{message}"
	end

	def convert_ruby_type_to_type(type, value_types = [])
		# puts "#{__method__} called with type '#{type.inspect}', #{type.class}, #{value_types.inspect}"
		# Because type is an instance of Class, we need to compare names, so convert to String
		# Use .to_s instead of .name to cope with custom types (i.e. types that are themselves new classes to be generated)
		case type.to_s
		when "Fixnum", "Integer"
			converted = convert_fixnum_to_type
		when "Float"
			converted = convert_float_to_type
		when "String"
			converted = convert_string_to_type
		when "TrueClass", "FalseClass"
			converted = convert_boolean_to_type
		when "Array"
			converted = convert_array_to_type(value_types)
		when "Hash"
			converted = convert_hash_to_type(value_types)
		when "NilClass" # default nil to String
			converted = convert_string_to_type
		else
			converted = convert_custom_class_type(type)
		end
		# puts "Converted '#{type.inspect}' to #{converted}"
		converted
	end

	# Translate "Fixnum" into the desired output language
	def convert_fixnum_to_type
		case @language
		when :java
			return "int"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Translate "Fixnum" into the desired output language
	def convert_float_to_type
		case @language
		when :java
			return "float"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Translate "Fixnum" into the desired output language
	def convert_boolean_to_type
		case @language
		when :java
			return "boolean"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Translate "String" into the desired output language
	def convert_string_to_type
		case @language
		when :java
			return "String"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Translate "Array" into the desired output language
	# Also needs the 'value types', i.e. what type is this array? A list of strings? A list of ints?
	def convert_array_to_type(value_types)
		error_and_exit "Detected an array, but could not determine the type of its children; found #{value_types.size} possibilities" unless value_types.size == 1
		case @language
		when :java
			return "List<#{convert_ruby_type_to_type(value_types[0])}>"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Translate "Hash" into the desired output language
	# Also needs the 'value types', i.e. what type is this hash? A map of strings to booleans? A map of ints to strings?
	def convert_hash_to_type(value_types)
		error_and_exit "Detected a hash, but could not determine the type of its keys and values; found #{value_types.size} possibilities" unless value_types.size == 2
		case @language
		when :java
			return "HashMap<#{convert_ruby_type_to_type(value_types[0])}, #{convert_ruby_type_to_type(value_types[1])}>"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns code representing the start of the class
	def convert_custom_class_type(type)
		case @language
		when :java, :ruby
			return type.capitalize_first_letter_only
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	def generate_top_level_name
		case @language
		when :java
			return "generatedFrom#{@mode.capitalize}"
		when :ruby
			return "generated_from_#{@mode}"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns an appropriately-formatted classname for the given name
	def generate_classname(name)
		case @language
		when :java, :ruby
			return name.capitalize_first_letter_only
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns an appropriately-formatted filename for the given name
	def generate_filename(name)
		case @language
		when :java
			return name.capitalize_first_letter_only + @extension
		when :ruby
			return name.downcase + @extension # TODO convert camelcase to underbarised case
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	def set_file_extension_for_language
		case @language
		when :java
			@extension = ".java"
		when :ruby
			@extension = ".rb"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns code representing the start of the class
	def generate_class_start(name)
		case @language
		when :java
			start = "public class #{convert_custom_class_type(name)} {"
		when :ruby
			start = "class #{convert_custom_class_type(name)}"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
		start
	end

	# Returns code representing the end of the class
	def generate_class_end
		case @language
		when :java
			class_end = "}"
		when :ruby 
			class_end = "end"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
		class_end
	end

	def generate_getter_and_setter(type, name)
		lines = []
		case @language
		when :java
			class_name = convert_custom_class_type(name)
			lines << "\t"
			lines << "\tpublic #{type} get#{class_name}() {"
			lines << "\t\treturn #{name};"
			lines << "\t}"
			lines << "\t"
			lines << "\tpublic void set#{class_name}(#{type} #{name}) {"		
			lines << "\t\tthis.#{name} = #{name};"
			lines << "\t}"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
		lines
	end

	# Returns code representing each of the supplied attributes
	def generate_code_from_attributes(attributes)
		case @language
		when :java
			return generate_java_code_from_attributes(attributes)
		when :ruby
			return generate_ruby_code_from_attributes(attributes)
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns Java code representing each of the supplied attributes
	def generate_java_code_from_attributes(attributes)
		code = []
		# Instance variables
		attributes.each do |att|
			code << "\tpublic #{convert_ruby_type_to_type(att[:type], att[:value_types])} #{att[:name]};"
		end

		#TODO constructor

		# Getters & setters
		attributes.each do |att|
			code << generate_getter_and_setter(convert_ruby_type_to_type(att[:type], att[:value_types]), att[:name])
		end
		code
	end

	# Returns Ruby code representing each of the supplied attributes
	def generate_ruby_code_from_attributes(attributes)
		code = []
		names = []
		attributes.each {|att| names << att[:name]}

		# Instance variables
		names.each do |name|
			code << "\tattr_accessor #{name.to_sym.inspect}"
		end
		code << "" # An empty string is enough to trigger a newline

		# Constructor
		code << "\tdef initialize(#{names.join(", ")})"
		names.each do |name|
			code << "\t\t@#{name} = #{name}"
		end
		code << "\tend"

		code
	end

	# From the supplied hash, generates code representing a class in the desired language (as a string)
	# Returns an array of hashes; each hash represents a file, with two keys : :name for filename (without extension), and :contents for file contents
	def generate_output_classes(hash, top_level_classname = nil)
		classname = generate_classname(top_level_classname)
		filename = generate_filename(classname)
		files = []
		this_file = {:name => classname, :name_with_ext => filename}
		lines = []
		lines << generate_class_start(classname)
		attributes = [] # array of hashes; keys => :name, :type, :value_types # :type, :value_types ([]) are initially kept as Ruby class names

		hash.each_pair do |k, v|
			attribute = {:name => k}
			if v.class == Array
				attribute[:type] = Array
				if v[0].class == Hash
					new_files = generate_output_classes(v[0], k)
					attribute[:value_types] = [new_files[0][:name]]
					files += new_files
				else
					# Array only contains primitives, not objects				
					attribute[:value_types] = [v[0].class]
				end			
			elsif v.class == Hash
				new_files = generate_output_classes(v, k)
				attribute[:type] = new_files[0][:name]
				files += new_files
			else
				attribute[:type] = v.class
			end
			attributes << attribute
		end

		lines << generate_code_from_attributes(attributes)
		lines << generate_class_end
		lines.flatten!
		this_file[:contents] = lines.join("\n")
		files.insert(0, this_file)
		files
	end

	###################################################################################################
	# The Generator
	###################################################################################################

	# Will generate classes from a SON file
	# Regardless of whether or not files are written, this will return an array of hashes; each hash represents a file, with two keys : :name for filename (without extension), and :contents for file contents
	#
	# dest_lang is symbol
	# file is filename & path
	# source_lang is symbol or nil (if nil, source language will be determined from the file extension)
	# make_file flag defaults to true; set to false if you do not want files to be created by this method
	# force_file flag is false; set to true if you wish to overwrite matching destination files (use with caution!)
	def ClassFromSON.generate_from_file(dest_lang, file, source_lang = nil, make_file = true, force_file = false)

		error_and_exit "Could not locate file #{file}" unless File.exists?(file)

		source_lang ||= File.extname(file).gsub(".", "")
		source = File.readlines(file).join
		ClassFromSON.generate(dest_lang, source, source_lang, make_file, force_file)

		# o = ClassFromSON.new
		# o.generate(dest_lang, source, source_lang, make_file)
	end

	# Will generate classes from a SON string
	# Regardless of whether or not files are written, this will return an array of hashes; each hash represents a file, with two keys : :name for filename (without extension), and :contents for file contents
	#
	# dest_lang is symbol
	# file is filename & path
	# source_lang is symbol
	# make_file flag defaults to true; set to false if you do not want files to be created by this method
	# force_file flag is false; set to true if you wish to overwrite matching destination files (use with caution!)
	def ClassFromSON.generate(dest_lang, source, source_lang, make_file = true, force_file = false)
		o = ClassFromSON.new
		o.generate(dest_lang, source, source_lang, make_file, force_file)
	end

	# Will generate classes from a SON string. 
	# Regardless of whether or not files are written, this will return an array of hashes; each hash represents a file, with two keys : :name for filename (without extension), and :contents for file contents
	#
	# dest_lang is symbol
	# file is filename & path
	# source_lang is symbol
	# make_file flag defaults to true; set to false if you do not want files to be created by this method
	# force_file flag is false; set to true if you wish to overwrite matching destination files (use with caution!)
	def generate(dest_lang, source, source_lang, make_file = true, force_file = false)

		error_and_exit "Please supply first argument as a Symbol" unless dest_lang.class == Symbol

		@language = dest_lang
		if @@target_languages.include?(@language)
			# may proceed
			# TODO other target languages, e.g. C#, Python
		else
			error_and_exit "Cannot generate language #{@language}; can only generate #{@@target_languages.join(", ")}"
		end
		@extension = set_file_extension_for_language

		@mode = source_lang.to_sym
		if @@input_modes.include?(@mode)
			# may proceed
		else
			error_and_exit "Cannot parse input language #{@mode}; can only parse #{@@input_modes.join(", ")}"
		end

		case @mode
		when :json
			hash = JSON.parse(source)
			# TODO other input languages, e.g. XML, YAML
		else
			error_and_exit "Cannot parse mode #{@mode}"
		end

		# If we have read in an array instead of a hash, then take the first element of the array
		# This assumes that each element in this top-level array has the same structure, which is reasonable
		if hash.class == Array && hash.size > 0
			hash = hash.shift
		end

		error_and_exit "Input file did not have a hash / map of key-value pairs; could not parse" unless hash.class == Hash

		error_and_exit "Input file hash / map was empty" if hash.empty?

		top_level_classname = generate_top_level_name
		output_classes = generate_output_classes(hash, top_level_classname).flatten # returns an array

		if make_file
			output_classes.each do |out|
				name = out[:name_with_ext]
				contents = out[:contents]
				unless force_file
					error_and_exit "Want to generate output file #{name}, but that file already exists" if File.exists?(name)
				end
				File.open(name, "w+") do |f|
					f.puts contents
				end
				puts "Wrote out file #{name}"
			end

			puts "Please inspect generated code files and adjust names and types accordingly"
		end
		output_classes
	end
end