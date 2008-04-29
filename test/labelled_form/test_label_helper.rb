require File.dirname(__FILE__) + '/../test_helper'

describe "label helpers" do
	
  context "label_tag" do

    context "with only a string" do

      before do
        @result = render(%{<%= label_tag('Address:') %>})
      end

      it "should generate a label tag using the string as the label" do
        @result.should have_tag('//label').with_text('Address:')
      end

    end
		
    context "with for and caption in the options hash" do

      before do
        @result = render(%{<%= label_tag(:for => :address, :caption => "Mailing Address:") %>})
      end

      it "should generate a label tag using the string as a label" do
        @result.should have_tag('//label[@for = "address"]')
        @result.should have_tag('//label').with_text('Mailing Address:')
      end
		
    end

    context "with only a caption" do

      before do
        @result = render(%{<%= label_tag(:caption => "Mailing Address:") %>})
      end

      it "should generate a label tag using the string as a label" do
        @result.should_not have_tag('//label[@for]')
        @result.should have_tag('//label').with_text('Mailing Address:')
      end
		
    end

    context "with for, a caption, and extra options" do

      before do
        @result = render(%{<%= label_tag(:for => :address, :caption => "Mailing Address:", :class => 'test') %>})
      end
      
      it "should generate a label tag and append options for the tag" do
        @result.should have_tag('//label[@for = "address"]')
        @result.should have_tag('//label[@class = "test"]')
        @result.should have_tag('//label').with_text('Mailing Address:')
      end

    end

	end
	
  context "generating a label for an attribute" do

    before do
      @result = render(%{<%= label(:var, :name) %>}, :name => 'test')
    end

    it "should use the humanized attribute name as the label" do
      @result.should have_tag('//label[@for = "var_name"]')
      @result.should have_tag('//label').with_text('Name:')
    end

  end
	
  context "generating a label from a form builder" do

    before do
      template = <<-EOF
        <% form_for(:var, @var) do |f| %>
        <%= f.label(:name) %>
        <% end %>
      EOF
      @result = render(template, :name => 'test')
    end

    it "should generate a label tag using the form builder's object" do
      @result.should have_tag('//label[@for = "var_name"]')
      @result.should have_tag('//label').with_text('Name:')
    end

	end

end
