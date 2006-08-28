require File.dirname(__FILE__) + '/../test_helper'

require 'quick_forms/css_helper'
include ActionView::Helpers

class CssHelperTest < Test::Unit::TestCase

	def test_class_name_valid
		assert CssClassList.class_name_valid?('valid_class'), "Valid CSS class was deemed invalid."
		assert !CssClassList.class_name_valid?('invalid class'), "Invalid CSS class was deemed valid."
	end

	def test_parse_string
		class_list = "one two three"
		assert_equal class_list.split(' '), CssClassList.parse_class_names(class_list),
		"String class list was incorrectly parsed."
	end
	
	def test_parse_array
		class_list = %w(one two three)
		assert_equal class_list, CssClassList.parse_class_names(class_list),
		"Array class list was incorrectly parsed."
	end
	
	def test_parse_nil
		assert_equal '', CssClassList.parse_class_names(nil).to_s
	end
	
	def test_parse_invalid
		assert_raise ArgumentError, "Invalid class list object was accepted" do
			CssClassList.parse_class_names(:invalid)
		end
	end

	def test_initialize
		class_list = "one two three"
		assert_equal class_list, CssClassList.new(class_list).to_s,
		"CSS class list was incorrectly initialized."
	end

end