class Assignment < ActiveRecord::Base
  belongs_to :users
  belongs_to :projects
  
   accepts_nested_attributes_for :users, :projects
   
   
   
    def self.project(query)
        where("project_id = ?", "#{query}")
    end
    
    def self.user(query)
        where("user_id = ?", "#{query}")
    end
    
    def self.get_id
        "#{user_id}"
    end
    
    def self.check(query1, query2)
        where("project_id = ? AND user_id = ?", "#{query1}","#{query2}")
    end
    
end
