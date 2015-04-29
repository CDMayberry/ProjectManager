class ProjectsController < ApplicationController
	include ApplicationHelper
	
           
	def index
		@projects = Project.all
		if params[:search] && params[:search] != ""
			#flash[:notice] = params[:options]
    		#@projects = Project.where(params[:options] "=" params[:search] )
    		if params[:options] == "title"
    			@projects = Project.title(params[:search]).order("created_at DESC")
    		end
    		if params[:options] == "company"
    			@projects = Project.company(params[:search]).order("created_at DESC")
    		end
    		if params[:options] == "start date"
    			@projects = Project.datestart(params[:search]).order("created_at DESC")
    		end
    		if params[:options] == "end date"
    			@projects = Project.dateend(params[:search]).order("created_at DESC")
    		end
    	else
    		@projects = Project.order("created_at DESC")
	 	end
	end

	def show
		@project = Project.find(params[:id])
		@assignment = Assignment.new
		@assignments = Assignment.project(params[:id])
		#@user = User.new
		@users = User.all
	end
	
	def new
		@project = Project.new
		@projects = Project.all
		@assignment = Assignment.new
		@assignments = Assignment.all
		#@projectusers = Assignment.where(:user_id => params[:user_id])
		@users = User.all
	end
	
	def edit
		@project = Project.find(params[:id])
		@projects = Project.all
		#@projectusers = Assignment.where(:user_id => params[:user_id])
		@assignments = Assignment.project(params[:id])
		#@assignments = Assignment.project(params[:id])
		@assignment = Assignment.new
		@users = User.all
	end
	
	
	def autofill
		
		# if(params[:proj_id].nil?)
		# 	@project = Project.new #Not correctly setting the data.
		# else
		# 	@project = Project.find(params[:proj_id])
		# end
		
		#Copy info from what the user entered.
		@project.title = project_params[:title]
		@project.company = project_params[:company]
		@project.start_date = project_params[:start_date]
		@project.end_date = project_params[:end_date]
		@project.description = project_params[:description]
		
		duration = params[:duration].to_i	
		schedule_date = 0	#The to-be-scheduled start date
		
		#Copy all project start and end times to a new array
		sortedProjects = []
		@projects.length.times do |i|
			sortedProjects << [@projects[i].start_date.to_date,@projects[i].end_date.to_date]
		end
		
		#Sort this new array by start date
		sortedProjects = sortedProjects.sort{|left,right| left[0].to_date <=> right[0].to_date}
		
		#Find where the new project fits in the schedule
		(sortedProjects.size()-1).times do |i|
			if (sortedProjects[i+1][0] - sortedProjects[i][1]).to_i >= duration
				schedule_date = sortedProjects[i][1]
				break
			end
		end
		#Check if it was scheduled above
		if schedule_date == 0
			schedule_date = sortedProjects[sortedProjects.size()-1][1]
		end
		
		#Set start date and end date
		@project.start_date = schedule_date
		@project.end_date = schedule_date + duration
		
		flash[:message] = "Automatically scheduled start and end date."
		
		#@form_value = params[:form_field] #form_field
		#Automatically fill in appropriate form elements
		#@form_value = "Livingstone Inc."
		#@project.company = saved_params.company #This works, but it doesn't grab the project correctly
		
	  	#render :template => "projects/_form", :locals => {:project => @project}
		#render 'edit'
		
	end
	
	def add_employee
  		@assignment = Assignment.find(params[:id])

  		respond_to do |format|
			format.js #add_question.js.erb
  		end
	end
	
	helper_method :autofill
	
	def create
		@projects = Project.all
		@users = User.all
		@assignment = Assignment.new
		@project = Project.new(project_params)
		@assignments = Assignment.project(params[:id])
		
		
		if params[:commit] == 'Create Project'
			#Create was pressed
			if @project.save		#Save the project
				redirect_to @project
				flash[:message] = "Successfully created project"
			else
				render 'edit'
			end
			
		elsif params[:commit] == 'Autofill'
			#Autofill was pressed
			self.autofill
			render 'new'
			
		elsif params[:assign_button] 
			if @project.save
				@test = params[:project]
				@assignment.user_id = @test["assignment"]["user_id"]
				@assignment.project_id = @project.id
				if @assignment.save
					flash[:message] = "Added New Team Member"
					flash[:ben_message] = @test["assignment"]["user_id"]
				else
					flash[:message] = "Error Adding Team Member"
					flash[:ben_message] = @assignment.user_id
				end
			else
				@project.errors.add(:team, "cannot add team member: Project not complete")
			end
			render 'new'
		end
		

		#if (params[:autofill_button] && @project.save) || !@project.save
		#	self.autofill
		#	flash[:message] = "Start and End Date automatically filled."
		#	render 'new'
		#else
		#	flash[:message] = "Successfully created project"
		#	redirect_to @project
		#end
		
		
	end
	
	def update
		@projects = Project.all
		@users = User.all
		@assignment = Assignment.new
		@assignments = Assignment.project(params[:id])
		@project = Project.find(params[:id])
		
		if params[:assign_button]
			@test = params[:project]
			@assignment.user_id = @test["assignment"]["user_id"]
			@assignment.project_id = params[:id]
			if @assignment.user_id.nil? || @assignment.project_id.nil?
				@project.errors.add(:select, "an employee")
				render 'edit'
				return
			end
			
			if Assignment.where(:project_id => @assignment.project_id,:user_id => @assignment.user_id).blank?
				if @assignment.save
					flash[:message] = "Added team member"
					#flash[:ben_message] = @test["assignment"]["user_id"]
				else
					flash[:message] = "Error Adding Team Member"
					flash[:ben_message] = @assignment.user_id
					
				end
			else
				@project.errors.add(:team, "member already on team")
			end
			render 'edit'
			return	
		end
		
		if params[:remove_button]
			@assigned = Assignment.find(params[:remove_button])
			@assigned.destroy
			render 'edit'
			return
		
		elsif params[:commit] == 'Autofill'
			#Autofill was pressed
			self.autofill
			render 'edit'
		
		elsif @project.update(project_params)
			redirect_to @project
		else
			render 'edit'			
		end
	end
	
	def destroy
  		@project = Project.find(params[:id])
		@assignments = Assignment.project(params[:id])
	  	@project.destroy
	 	@assignments.each do |assign|
	 		assign.destroy
	 	end
	 
	  redirect_to projects_path
	end
	
	def search
		
	end
	
	private
		def project_params
			params.require(:project).permit(:title,:company,:start_date,:end_date,:description, project_assignments_attributes: [:id, :user_id, :assign_id])
		end
		
		def all_params
			params.permit(:title,:company,:start_date,:end_date,:description, :user_id,:duration)	
		end
		
		def assign_params
			params.permit(:proj_id, :user_id)
		end 
		
		def saved_params
			params.require(:project)
		end
end

