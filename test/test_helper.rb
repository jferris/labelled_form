require 'test/unit'
require 'ostruct'
require 'rubygems'
require_gem 'actionpack'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'
require_gem 'activerecord'
require 'active_record'
require 'active_record/fixtures'

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '../lib'))

ActionController::Base.template_root = File.join(File.dirname(__FILE__), 'views')

require File.join(File.dirname(__FILE__), '../init')

ActionController::Routing::Routes.draw do |map|
	map.connect ':controller/:action/:id'
end

class TestController < ActionController::Base

	attr_accessor :template_string, :var

	def rescue_action (e)
		raise e
	end
	
	def test
		render :inline => template_string
	end

end

class Test::Unit::TestCase

	self.use_transactional_fixtures = true
	self.use_instantiated_fixtures  = false
	self.fixture_path = File.dirname(__FILE__) + '/fixtures'
	
	def render (template, var = nil)
		@controller	= TestController.new
		@request	= ActionController::TestRequest.new
		@response	= ActionController::TestResponse.new
		
		@controller.template_string = template
		@controller.var = OpenStruct.new(var)
		
		get :test
		assert_response :success
		
		@response.body
	end

end

require 'schema'
require 'models'

ActiveRecord::Base.establish_connection(
	:adapter	=> 'mysql',
	:socket		=> '/var/run/mysqld/mysqld.sock',
	:database	=> 'rubytest',
	:username	=> 'root',
	:password	=> ''
)

require 'labelled_form'

DatabaseSchema.verbose = false
begin
	DatabaseSchema.migrate(:down)
rescue
end
DatabaseSchema.migrate(:up)