require "test/unit"
require_relative "../lib/class_from_son"

class TestEx < Test::Unit::TestCase

    def switch_dir
        # Change this to more easily find the test files
        @previous_wd ||= Dir.getwd # Preserve the old wd so we can switch back to it after the test
        Dir.chdir File.expand_path(File.dirname(__FILE__))    
    end

    # Switch to the same directory as this unit-test file
    def setup
        switch_dir
    end

	def test_class_from_json_to_ruby
		json = File.readlines("testjson.json").join
		
		address_filename = "address.rb"
		top_level_filename = "generated_from_json.rb"
		phonenumbers_filename = "phonenumbers.rb"

		expected_address = File.readlines(address_filename).join.chomp # trim off any trailing whitespace (irrelevent for this test)
		expected_example = File.readlines(top_level_filename).join.chomp # trim off any trailing whitespace (irrelevent for this test)
		expected_phonenumbers = File.readlines(phonenumbers_filename).join.chomp # trim off any trailing whitespace (irrelevent for this test)
		
		generated = nil
		assert_nothing_raised("ClassFromSON.generate exited with an error") { generated = ClassFromSON.generate(:ruby, json, :json, false) }

		assert_equal(3, generated.size, "Failed to correctly generate all Ruby classes from JSON")

		assert_equal(top_level_filename, generated[0][:name_with_ext], "Failed to correctly generate top-level generated_from_json example filename")
		assert_equal(address_filename, generated[1][:name_with_ext], "Failed to correctly generate address example filename")
		assert_equal(phonenumbers_filename, generated[2][:name_with_ext], "Failed to correctly generate phonenumbers example filename")

		assert_equal(expected_example, generated[0][:contents], "Failed to correctly generate top-level GeneratedFromJson example Ruby class from JSON")
		assert_equal(expected_address, generated[1][:contents], "Failed to correctly generate Address example Ruby class from JSON")
		assert_equal(expected_phonenumbers, generated[2][:contents], "Failed to correctly generate PhoneNumbers example Ruby class from JSON")
	end


	def test_class_from_json_to_java
		json = File.readlines("testjson.json").join
		
		address_filename = "Address.java"
		top_level_filename = "GeneratedFromJson.java"
		phonenumbers_filename = "PhoneNumbers.java"

		expected_address = File.readlines(address_filename).join.chomp # trim off any trailing whitespace (irrelevent for this test)
		expected_example = File.readlines(top_level_filename).join.chomp # trim off any trailing whitespace (irrelevent for this test)
		expected_phonenumbers = File.readlines(phonenumbers_filename).join.chomp # trim off any trailing whitespace (irrelevent for this test)
		
		generated = nil
		assert_nothing_raised("ClassFromSON.generate exited with an error") { generated = ClassFromSON.generate(:java, json, :json, false) }

		assert_equal(3, generated.size, "Failed to correctly generate all Java classes from JSON")

		assert_equal(top_level_filename, generated[0][:name_with_ext], "Failed to correctly generate top-level GeneratedFromJson example filename")
		assert_equal(address_filename, generated[1][:name_with_ext], "Failed to correctly generate Address example filename")
		assert_equal(phonenumbers_filename, generated[2][:name_with_ext], "Failed to correctly generate PhoneNumbers example filename")

		assert_equal(expected_example, generated[0][:contents], "Failed to correctly generate top-level GeneratedFromJson example Java class from JSON")
		assert_equal(expected_address, generated[1][:contents], "Failed to correctly generate Address example Java class from JSON")
		assert_equal(expected_phonenumbers, generated[2][:contents], "Failed to correctly generate PhoneNumbers example Java class from JSON")
	end


    # Restore the working directory to what it was previously
    def teardown
        Dir.chdir @previous_wd # restore the working directory to what it was previously
    end
end