class ProjectsController < ApplicationController
	include ApplicationHelper
	
	
	#Function to interpret date according to a variety of common formats
	def interpretDate(dateString)
		
		begin
		
		if (dateString =~ /^\d\d?\/\d\d?\/(\d\d)$/ )
		    #puts "Format: m/d/y"
		    searchDate = Date.strptime(dateString, '%m/%d/%y')
		elsif (dateString =~ /^\d\d?\/\d\d?\/(\d\d\d\d)$/ )
		    #puts "Format: m/d/Y"
		    searchDate = Date.strptime(dateString, '%m/%d/%Y')
		elsif (dateString =~ /^\d\d?\.\d\d?\.(\d\d)$/ )
		    #puts "Format: m.d.y"
		    searchDate = Date.strptime(dateString, '%m.%d.%y')
		elsif (dateString =~ /^\d\d?\.\d\d?\.(\d\d\d\d)$/ )
		    #puts "Format: m.d.Y"
		    searchDate = Date.strptime(dateString, '%m.%d.%Y')
		elsif (dateString =~ /^\d\d?\-\d\d?\-(\d\d)$/ )
		    #puts "Format: m-d-y"
		    searchDate = Date.strptime(dateString, '%m-%d-%y')
		elsif (dateString =~ /^\d\d?\-\d\d?\-(\d\d\d\d)$/ )
		    #puts "Format: m-d-Y"
		    searchDate = Date.strptime(dateString, '%m-%d-%Y')
		else
			flash[:message] = "Unrecognized date format. Use mm.dd.yy or mm.dd.yyyy."
		    return nil
		end
		
		rescue ArgumentError => bang
			flash[:message] = "Invalid date. (Use month first, then day, then year)."
			return nil
		end
		
		
	end
	
	
	
	
	           
	def index
		@projects = Project.all
		if params[:search] && params[:search] != ""
			
			#flash[:notice] = params[:options]
    		#@projects = Project.where(params[:options] "=" params[:search] )
    		if params[:options] == "title"
    			@projects = Project.title(params[:search]).order("start_date ASC")
    		end
    		if params[:options] == "company"
    			@projects = Project.company(params[:search]).order("start_date ASC")
    		end
    		if params[:options] == "start date"
    			tempDate = interpretDate(params[:search])
    			if tempDate == nil
    				return
    			end
    			@projects = Project.datestart(tempDate.strftime("%Y-%m-%d")).order("start_date ASC")
    		end
    		if params[:options] == "end date"
    			tempDate = interpretDate(params[:search])
    			if tempDate == nil
    				return
    			end
    			@projects = Project.dateend(tempDate.strftime("%Y-%m-%d")).order("start_date ASC")
    		end
    	else
    		@projects = Project.order("start_date ASC")
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
		@assignments = Assignment.project(-1)
		#@projectusers = Assignment.where(:user_id => params[:user_id])
		@users = User.all
		@user_array = []
	end
	
	def edit
		@project = Project.find(params[:id])
		@projects = Project.all
		#@projectusers = Assignment.where(:user_id => params[:user_id])
		@assignments = Assignment.project(params[:id])
		@assignment = Assignment.new
		@users = User.all
		@user_array = []
		@assignments.each do |set|
			@user_array << set.user_id
		end
		
	end
	
	
	def autofill
		#Copy info from what the user entered.
		@project.title = project_params[:title]
		@project.company = project_params[:company]
		@project.start_date = project_params[:start_date]
		@project.end_date = project_params[:end_date]
		@project.description = project_params[:description]
		@user_array = params[:assignees]
		
		if params[:duration].to_s == ""
			flash[:message] = "No duration specified."
		else
			duration = params[:duration].to_i	
			schedule_date = 0	#The to-be-scheduled start date
			
			#Copy all project start and end times to a new array
			#Only include projects with team member overlap
			sortedProjects = []
			@projects.length.times do |i|	#For each project,
				
				#Assignments for this particular project
				assignments = Assignment.project(@projects[i].id)
				
				#Enumerate the members on the project
				temp_array = []
				assignments.each_with_index do |set,i|
					temp_array << set.user_id.to_s	#Must convert to string for compatibility
				end
				
				#If members overlap with new project, consider it a conflict
				#Also only consider projcets with end dates in the future
				if temp_array && @user_array && (temp_array & @user_array).size() > 0 && @projects[i].end_date.to_date > Time.current.to_date
					sortedProjects << [@projects[i].start_date.to_date,@projects[i].end_date.to_date]
				end
				
			end
			
			#Sort array of conflicting projects by start date
			sortedProjects = sortedProjects.sort{|left,right| left[0].to_date <=> right[0].to_date}
			
			#See if new project fits before schedule
			if sortedProjects.size() > 0 && ((sortedProjects[0][0] - Time.current.to_date).to_i >= duration)
				schedule_date = Time.current.to_date
			else
				#Find where the new project fits in the schedule
				(sortedProjects.size()-1).times do |i|
					if (sortedProjects[i+1][0] - sortedProjects[i][1]).to_i >= duration
						schedule_date = sortedProjects[i][1]
						break
					end
				end
				
			end
			
			#Check if it was scheduled above
			if schedule_date == 0 && sortedProjects.size() > 0
				schedule_date = sortedProjects[sortedProjects.size()-1][1]
			elsif schedule_date == 0
				schedule_date = Time.current.to_date
			end
			
			#Set start date and end date
			@project.start_date = schedule_date
			@project.end_date = schedule_date + duration
			
		end
		
	end
	
	helper_method :autofill
	helper_method :date_validation
	
	def create	#All buttons on creation page pass through here.
		@projects = Project.all
		@users = User.all
		@assignment = Assignment.new
		@project = Project.new(project_params)
		@assignments = Assignment.project(params[:id])
		@user_array = params[:assignees]
		
		if @user_array
			flash[:message] = @user_array
		else
			@user_array = []
		end
		
		
		if params[:commit] == 'Create Project'
			#Create was pressed
			if @project.save		#Save the project
				@user_array.each do |assign|
					@assignee = Assignment.new
					@assignee.user_id = assign
					@assignee.project_id = @project.id
					@assignee.save
				end
			
				redirect_to @project
				flash[:message] = "Successfully created project"
				return
			else
				render 'new'
				return
			end
			
		elsif params[:commit] == 'Autofill'
			#Autofill was pressed
			self.autofill
			render 'new'
			return
			
		# elsif params[:commit]
		# 	flash[:message] = params[:commit]
		# 	render 'new'
		# 	return check line 121
		
		elsif params[:assign_button]

			@temp = params[:project]
			@assignment.user_id = @temp["assignment"]["user_id"]
			@assignment.project_id = @project.id
	
			if @temp && !@user_array.include?(@temp["assignment"]["user_id"]) #Need to add functionality to check if ID is present
				@user_array << @temp["assignment"]["user_id"]
				#flash[:message] = @user_array
			else
				flash[:message] = "Duplicate found"
			end
			
			render 'new'
			return
		
		elsif params[:remove_member]
		
			#Remove the member from the array
			@user_array.delete(params[:remove_member])
		
			flash[:message] ="Removed member: " + @users.find(params[:remove_member]).last_name 
			
			render 'new'
			return
			

		else
			flash[:message] = "Missed everything else"
			render 'new'
		end
		
	end
	
	def update
		@projects = Project.all
		@users = User.all
		@assignment = Assignment.new
		@assignments = Assignment.project(params[:id])
		@project = Project.find(params[:id])
		@user_array = params[:assignees]
		
		if @user_array
			flash[:message] = @user_array
		else
			@user_array = []
		end
		
		
		if params[:assign_button]
			@temp = params[:project]
			@assignment.user_id = @temp["assignment"]["user_id"]
			@assignment.project_id = @project.id
	
			if @temp && !@user_array.include?(@temp["assignment"]["user_id"]) #Need to add functionality to check if ID is present
				@user_array << @temp["assignment"]["user_id"]
				#flash[:message] = @user_array
			else
				flash[:message] = "Duplicate found"
			end
			
			render 'edit'
			return
			# if @assignment.user_id.nil? || @assignment.project_id.nil?
			# 	@project.errors.add(:select, "an employee")
			# 	render 'edit'
			# 	return
			# end
			
			# if Assignment.where(:project_id => @assignment.project_id,:user_id => @assignment.user_id).blank?
			# 	if @assignment.save
			# 		flash[:message] = "Added team member"
			# 		#flash[:ben_message] = @test["assignment"]["user_id"]
			# 	else
			# 		flash[:message] = "Error Adding Team Member"
			# 		flash[:ben_message] = @assignment.user_id
					
			# 	end
			# else
			# 	@project.errors.add(:team, "member already on team")
			# end
		elsif params[:remove_member]
		
			#Remove the member from the array
			@user_array.delete(params[:remove_member])
		
			flash[:message] ="Removed member: " + @users.find(params[:remove_member]).last_name 
			render 'edit'
			return			
		end
		
		if params[:commit] == 'Autofill'
			#Autofill was pressed
			self.autofill
			render 'edit'
		
		elsif @project.update(project_params)
				@assignments.each do |assign|
					assign.destroy
				end
				
				@user_array.each do |assign|
					@assignee = Assignment.new
					@assignee.user_id = assign
					@assignee.project_id = @project.id
					@assignee.save
				end		
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

