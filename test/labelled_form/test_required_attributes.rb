require File.dirname(__FILE__) + '/../test_helper'

context "required attributes" do
	
  it "should return the correct attributes for required_attributes_by_on" do
		Person.required_attributes_by_on.should == { :save => [:name] }
	end
	
  it "should return an array of required attributes" do
		Person.new.required_attributes.should == [:name]
	end
	
  it "should return true if an attribute is required" do
		person = Person.new
		
		person.attribute_required?(:name).should == true
		!person.attribute_required?(:address).should == true
	end
	
end
