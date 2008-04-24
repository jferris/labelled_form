require File.dirname(__FILE__) + '/../test_helper'

describe "label helpers" do
	
  context "label_tag" do

    context "with only a symbol" do

      before do
        render(%{<%= label_tag(:address) %>})
      end

      it "should generate a label tag using the humanized symbol as the label" do
        response.should have_tag('label')
        response.should have_tag('label[for = ?]')
        response.should have_tag('label', 'Address:')
      end

    end
		
    context "with a symbol and a string" do

      before do
        result = render(%{<%= label_tag(:address, "Mailing Address:") %>})
      end

      it "should generate a label tag using the string as a label" do
        assert_tag :tag => 'label',
        :attributes => {:for => 'address'},
        :content => 'Mailing Address:'
      end
		
    end

    context "with nil and a string" do

      before do
        result = render(%{<%= label_tag(nil, "Mailing Address:") %>})
      end

      it "should generate a label tag using the string as a label" do
        assert_tag :tag => 'label',
        :attributes => {:for => nil},
        :content => 'Mailing Address:'
      end
		
    end

    context "with a symbol, a string, and an options hash" do

      before do
        result = render(%{<%= label_tag(:address, "Mailing Address:", :class => 'test') %>})
      end
      
      it "should generate a label tag and append options for the tag" do
        assert_tag :tag => 'label',
        :attributes => {:for => 'address', :class => 'test'},
        :content => 'Mailing Address:'
      end

    end

	end
	
  context "generating a label for an attribute" do

    before do
      render(%{<%= label(:var, :name) %>}, :name => 'test')
    end

    it "should use the humanized attribute name as the label" do
      assert_tag :tag => 'label',
      :attributes => {:for => 'var_name'},
      :content => 'Name:'
    end

  end
	
  context "generating a label from a form builder" do

    before do
      template = <<-EOF
        <% form_for(:var, @var) do |f| %>
        <%= f.label(:name) %>
        <% end %>
      EOF
      render(template, :name => 'test')
    end

    it "should generate a label tag using the form builder's object" do
      assert_tag :tag => 'label',
      :attributes => {:for => 'var_name'},
      :content => 'Name:'
    end

	end

end
