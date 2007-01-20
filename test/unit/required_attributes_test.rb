require File.dirname(__FILE__) + '/../test_helper'

class RequiredAttributesTest < Test::Unit::TestCase
	
	def test_required_attributes_by_on
		expected = {
			:save => [:name]
		}
		assert_equal expected, Person.required_attributes_by_on, "The correct required attributes should be returned"
	end
	
	def test_required_attributes
		person = Person.new
		assert_equal [:name], person.required_attributes
	end
	
	def test_attribute_required
		person = Person.new
		
		assert person.attribute_required?(:name), "The name attribute should be required"
		assert !person.attribute_required?(:address), "The address attribute should not be required"
	end
	
end