class AssignmentsController < ApplicationController
	
	validates :user_id, presence: true
	validates :project_id, presence: true
	
    def index
    	@assignments = Assignment.all 
    end
	
	def new
		@assignment = Assignment.new
	end
	
	def create
		@projects = Project.all
		@users = User.all
		@assignment = Assignment.new(assignment_params)
		#@project = Project.new(project_params)

		#Don't save the assignment until the project is saved
		#if @assignment.save
			
			#self.autofill
			#flash[:notice] = "Autofilling project"
			
		#else
			#flash[:notice] = "Successfully created project."
			#redirect_to @assignment
		#end
		
		
	end

	def update
		@projects = Project.all
		@users = User.all
		@assignment = Assignment.find(params[:id])
        @assignments = Assignment.all
        #@project = Project.find(params[:id])
		#@user = User.find(params[:id])
		
		if @assignment.update(assignment_params)
			redirect_to @assignment
		else
			render 'edit'			
		end
	end
	
	def destroy
		@assignments = Assignment.all
	  	@assignment = Assignment.find(params[:id])
	  	@assignment.destroy
	 
		render 'projects/edit'
	end
	
	private
	
	def assignment_params
		params.require(:assignment).permit(:user_id,:project_id)
	end
	
end
