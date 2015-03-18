class Project < ActiveRecord::Base
    #attr_accessible :employee_id
    has_many :assignments
    has_many :employees, :through => :assignments
end
