class Project < ActiveRecord::Base
	serialize :employees,Array
	
	validates :title, presence: true,
				length: { minimum: 5 }

	def change
		create_table :projects do |t|
			t.string :title
			t.start_date :date
			t.end_date :date
			t.employees :array
			t.description :text
			   
			t.timestamps null: false
		end
	end
end
