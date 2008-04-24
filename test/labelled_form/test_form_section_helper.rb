require File.dirname(__FILE__) + '/../test_helper'

describe "form section helpers" do
	
  context "building a form section" do

    before do
      template = <<-end_template
        <%
          s = Object.new
          class << s
            include Helpers::FormSectionBuilder
          end
          s.section_title = 'Section Title'
        %>
        <% s.info do %>
          <p>I am the info</p>
        <% end %>
        <% s.body do %>
          <p>I am the body</p>
        <% end %>
        <%= s.output %>
      end_template
      @result = render(template)
    end

    it "should create a section_info div" do
      @result.should have_tag('div[@class = "section_info"]')
    end
		
    it "should create a title section" do
      @result.should have_text('//h2', 'Section Title')
    end

    it "should create an info section" do
      @result.should have_text('.section_info p', 'I am the info')
    end

    it "should create a body section"do
      @result.should have_text('.section_body p', 'I am the body')
    end

	end
	
  context "creating a form section" do

    before do
      template = <<-end_template
        <% form_section(:title => 'Section Title') do |s| %>
          <% s.info do %>
            <p>I am the info</p>
          <% end %>
          <% s.body do %>
            <p>I am the body</p>
          <% end %>
        <% end %>
      end_template
      @result = render(template)
    end
      
    it "should create a div for the section" do
      @result.should have_tag('//div[@class = "section"]')
    end

  end
	
  context "create a form section for an object" do

    before do
      template = <<-end_template
        <% form_section_for(:var, @var, :title => 'Section Title') do |s| %>
          <% s.info do %>
            <p>I am the info</p>
          <% end %>
          <% s.body do %>
            <%= s.text_field :name %>
          <% end %>
        <% end %>
      end_template
      @result = render(template, :name => 'test')
    end
		
    it "should create the section body" do
      @result.should have_tag('//div[@class = "section_body"]')
      @result.should have_tag('//div/input')
    end

	end
	
end
