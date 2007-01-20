class DatabaseSchema < ActiveRecord::Migration
	
	def self.up
		create_table :person, :force => true do |t|
			t.column :name, :string, :null => false
		end
	end	
	
end