class AssignmentsController < ApplicationController
	
    def index
    	@assignment = Assignment.all 
    end
	
	def new
		@assignment = Assignment.new
	end

end
