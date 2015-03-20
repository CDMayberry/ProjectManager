class Project < ActiveRecord::Base
 
    #scope :starts_with, -> (name) { where("name like ?", "#{name}%")}

	validates :title, presence: true,
                    length: { minimum: 5 }	
    validates :company, presence: true,
                    length: { minimum: 2 }
                    
    def self.search(query)
        # where(:title, query) -> This would return an exact match of the query
        where("title like ? or company like ? or start_date like ? or end_date like ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%") 
    end
    
    has_many :assignments
    has_many :employees, :through => :assignments
end
