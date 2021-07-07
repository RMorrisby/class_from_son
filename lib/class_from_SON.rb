require "json"
require "more_ruby"

# A utility to convert an input file of string-object notation, e.g. JSON, XML, YAML, and generate code that looks like a class of your desired language

class ClassFromSON

	@@target_languages = [:java, :java_lombok, :ruby]
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
		when :java, :java_lombok
			return "int"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Translate "Fixnum" into the desired output language
	def convert_float_to_type
		case @language
		when :java, :java_lombok
			return "float"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Translate "Fixnum" into the desired output language
	def convert_boolean_to_type
		case @language
		when :java, :java_lombok
			return "boolean"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Translate "String" into the desired output language
	def convert_string_to_type
		case @language
		when :java, :java_lombok
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
		when :java, :java_lombok
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
		when :java, :java_lombok
			return "HashMap<#{convert_ruby_type_to_type(value_types[0])}, #{convert_ruby_type_to_type(value_types[1])}>"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns code representing the start of the class
	def convert_custom_class_type(type)
		case @language
		when :java, :java_lombok, :ruby
			return type.capitalize_first_letter_only
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	def generate_top_level_name
		case @language
		when :java, :java_lombok
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
		when :java, :java_lombok, :ruby
			return name.capitalize_first_letter_only
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns an appropriately-formatted filename for the given name
	def generate_filename(name)
		case @language
		when :java, :java_lombok
			return name.capitalize_first_letter_only + @extension
		when :ruby
			return name.snakecase + @extension
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	def set_file_extension_for_language
		case @language
		when :java, :java_lombok
			@extension = ".java"
		when :ruby
			@extension = ".rb"
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns code representing the start of the class
	def generate_class_start(name)
		# TODO make this more readable
		case @language
		when :java
			start = <<-START

import com.fasterxml.jackson.annotation.JsonProperty;

public class #{convert_custom_class_type(name)} {
START
		when :java_lombok
			start = <<-START

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@JsonInclude(Include.NON_NULL)
@NoArgsConstructor // Need @NoArgsConstructor for JSON deserialisation
@AllArgsConstructor // Need @AllArgsConstructor for @Builder
@Builder
@Getter
@Setter
public class #{convert_custom_class_type(name)} {
START
		when :ruby
			case @mode
			when :json
			start = <<-START
require 'json'

class #{convert_custom_class_type(name)}
START
			else 
				error_and_exit "Cannot parse mode #{@mode}"
			end
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
		start
	end

	# Returns code representing the end of the class
	def generate_class_end
		case @language
		when :java, :java_lombok
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
		when :java_lombok
			# do nothing - Lombok's raison d'etre is to avoid getters & setters
		when :java
			# This is safe even if the name is already in snakecase
			field_name_for_getter = name.snakecase.pascalcase

			name = name.camelcase if name.include? "_"
				
			lines << "\t"
			lines << "\tpublic #{type} get#{field_name_for_getter}() {"
			lines << "\t\treturn #{name};"
			lines << "\t}"
			lines << "\t"
			lines << "\tpublic void set#{field_name_for_getter}(#{type} #{name}) {"		
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
		when :java, :java_lombok
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
			if att[:name].include? "_"
				snakecase_name = att[:name]
				camelcase_name = att[:name].camelcase
				code << "\t@JsonProperty(\"#{snakecase_name}\")"
				code << "\tprivate #{convert_ruby_type_to_type(att[:type], att[:value_types])} #{camelcase_name};"
				code << "" # add a new line so that fields are separated & easier to read
			else 
				code << "\tprivate #{convert_ruby_type_to_type(att[:type], att[:value_types])} #{att[:name]};"
			end
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
		attributes.each {|att| names << att[:name].snakecase}

		# Instance variables
		names.each do |name|
			code << "  attr_accessor #{name.to_sym.inspect}"
		end
		code << "" # An empty string is enough to trigger a newline

		# Constructor
		# This is deliberately commented out, in favour of self.from_hash
		code << "  # Using self.from_hash(hash) is usually better, but this code is here in case you prefer this style of constructor"
		code << "  # def initialize(#{names.join(", ")})"
		names.each do |name|
			code << "    # @#{name} = #{name}"
		end
		code << "  # end"
		code
	end

	# Returns code for a from_SON and to_SON method
	def generate_from_and_to_methods(classname, attributes)
		case @language
		when :java, :java_lombok
			return generate_java_from_and_to_methods(classname, attributes)
		when :ruby
			return generate_ruby_from_and_to_methods(classname, attributes)
		else 
			error_and_exit "Could not convert to output language #{@language}"
		end
	end

	# Returns Java code for a from_SON and to_SON method
	def generate_java_from_and_to_methods(classname, attributes)
		code = []
		# TODO
		code
	end

	# Returns Ruby code for a from_SON and to_SON method
	def generate_ruby_from_and_to_methods(classname, attributes)
		code = []
		names = []
		attributes.each {|att| names << att[:name].snakecase}

		# from_hash method
		code << ""
		code << "  def self.from_hash(h)"
		code << "    o = self.new"
		names.each do |name|
			code << "    o.#{name} = h[:#{name}]"
		end
		code << "    o"
		code << "  end"

		# from_SON method
		code << ""
		code << "  def self.from_#{@mode}(#{@mode})"
		case @mode
		when :json
			code << "    self.from_hash(JSON.parse(#{@mode}, :symbolize_names => true))"
			# TODO other input languages, e.g. XML, YAML
		end
		code << "  end"
		
		# to_hash method
		code << ""
		code << "  def to_hash"
		code << "    h = {}"
		names.each do |name|
			code << "    h[:#{name}] = @#{name}"
		end
		code << "    h"
		code << "  end"

		# to_SON method & alias
		code << ""
		code << "  def to_#{@mode}"
		case @mode
		when :json
			code << "    JSON.generate(to_hash)"
			# TODO other input languages, e.g. XML, YAML
		end
		code << "  end"
		case @mode
		when :json
			code << "  alias to_s to_json"
			# TODO other input languages, e.g. XML, YAML
		end
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
		lines << generate_from_and_to_methods(classname, attributes)
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
	# lenient_mode flag is true; if the SON contains different objects with the same name (e.g. "data") then these will be treated
	#    as different objects with a _1, _2, etc. suffix. If this flag is false and these different objects are present, then errors will occur
	# custom_file_path is nil; set to an absoulte or relative path to have the new files be written to that location
	def ClassFromSON.generate_from_file(dest_lang, file, source_lang = nil, make_file = true, force_file = false, lenient_mode = true, custom_file_path = nil)

		error_and_exit "Could not locate file #{file}" unless File.exists?(file)

		source_lang ||= File.extname(file).gsub(".", "")
		source = File.readlines(file).join
		ClassFromSON.generate(dest_lang, source, source_lang, make_file, force_file, lenient_mode, custom_file_path)

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
	# lenient_mode flag is true; if the SON contains different objects with the same name (e.g. "data") then these will be treated
	#    as different objects with a _1, _2, etc. suffix. If this flag is false and these different objects are present, then errors will occur
	# custom_file_path is nil; set to an absoulte or relative path to have the new files be written to that location
	def ClassFromSON.generate(dest_lang, source, source_lang, make_file = true, force_file = false, lenient_mode = true, custom_file_path = nil)
		o = ClassFromSON.new
		o.generate(dest_lang, source, source_lang, make_file, force_file, lenient_mode, custom_file_path)
	end

	# Will generate classes from a SON string. 
	# Regardless of whether or not files are written, this will return an array of hashes; each hash represents a file, with two keys : :name for filename (without extension), and :contents for file contents
	#
	# dest_lang is symbol
	# file is filename & path
	# source_lang is symbol
	# make_file flag defaults to true; set to false if you do not want files to be created by this method
	# force_file flag is false; set to true if you wish to overwrite matching destination files (use with caution!)
	# lenient_mode flag is true; if the SON contains different objects with the same name (e.g. "data") then these will be treated
	#    as different objects with a _1, _2, etc. suffix. If this flag is false and these different objects are present, then errors will occur
	# custom_file_path is nil; set to an absoulte or relative path to have the new files be written to that location
	def generate(dest_lang, source, source_lang, make_file = true, force_file = false, lenient_mode = true, custom_file_path = nil)

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

		# TODO other input languages, e.g. XML, YAML
		case @mode
		when :json
			begin
				hash = JSON.parse(source)
			rescue JSON::ParserError => e
				error_and_exit "Could not parse supplied string as JSON. Error message : #{e.message}"
			end
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

		# Set the directory that the files will be written into
		if custom_file_path
			# This caters for both absolute & relative file paths
			file_path = File.absolute_path(custom_file_path)
		else
			file_path = Dir.getwd
		end

		# Track the names of the classes/files we have written so far
		written_file_names = []

		if make_file
			output_classes.each do |out|
				name = out[:name_with_ext]
				# Check the name against the files we have already written
				if written_file_names.include?(name)
					if lenient_mode
						# Let us increment the name, e.g. "data.rb" -> "data_1.rb", "data_2.rb", etc.
						increment = 1
						new_name = name.gsub(@extension, "_#{increment}#{@extension}")
						while written_file_names.include?(new_name)
							increment += 1
							new_name = name.gsub(@extension, "_#{increment}#{@extension}")
						end
						name = new_name
					else
						message = "Want to generate output file #{name}, but a file with that name has already been written by this process. Your SON structure contains 2+ different classes with the same name"
						error_and_exit(message) 
					end
				end

				filename = file_path + File::SEPARATOR + name
				contents = out[:contents]
				unless force_file
					error_and_exit "Want to generate output file #{name}, but that file already exists" if File.exists?(name)
				end
				File.open(filename, "w+") do |f|
					f.puts contents
				end
				written_file_names << name
				puts "Wrote out file #{name}"
			end

			puts "Please inspect generated code files and adjust names and types accordingly"
		end
		output_classes
	end
end