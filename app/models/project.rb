class Project < ActiveRecord::Base
    
    # where(:title, query) -> This would return an exact match of the query
    # scope :starts_with, -> (name) { where("name like ?", "#{name}%")}

	validates :title, presence: true,
                    length: { minimum: 5 }	
    validates :company, presence: true,
                    length: { minimum: 2 }
    validates :start_date, presence: true    
    validates :end_date, presence: true
    #validates :start_date < :end_date
    
    # validate :dates

    # def self.dates
    #     if end_date && start_date
    #         errors.add(:end_date, "Start date must be before end date") if end_date < start_date
    #     end
    # end
                    
    def self.search(query)
        where("title like ? or company like ? or start_date like ? or end_date like ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%") 
    end
    
    def self.title(query)
        where("title like ?", "%#{query}%")
    end
    
    def self.company(query)
        where("company like ?", "%#{query}%")
    end
    
    def self.datestart(query)
        where("start_date like ?", "%#{query}%")
    end
    
    def self.dateend(query)
        where("company like ?", "%#{query}%")
    end
    
    has_many :assignments
    has_many :users, :through => :assignments
    accepts_nested_attributes_for :assignments
end
