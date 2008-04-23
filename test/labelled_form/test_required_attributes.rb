require File.dirname(__FILE__) + '/../test_helper'

context "required attributes" do
	
  it "should return the correct attributes for required_attributes_by_on" do
		expected = {
			:save => [:name]
		}
		assert_equal expected, Person.required_attributes_by_on, "The correct required attributes should be returned"
	end
	
  it "should return an array of required attributes" do
		person = Person.new
		assert_equal [:name], person.required_attributes
	end
	
  it "should return true if an attribute is required" do
		person = Person.new
		
		assert person.attribute_required?(:name), "The name attribute should be required"
		assert !person.attribute_required?(:address), "The address attribute should not be required"
	end
	
end
