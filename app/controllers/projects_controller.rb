class ProjectsController < ApplicationController

           
	def index
		@projects = Project.all
		if params[:search]
    		@projects = Project.search(params[:search]).order("created_at DESC")
    	else
    		@projects = Project.order("created_at DESC")
	 	end
	end

	def show
		@project = Project.find(params[:id])
	end
	
	def new
		@project = Project.new
	end
	
	def edit
		@project = Project.find(params[:id])
	end
	
	def create
		@project = Project.new(project_params)
		if @project.save
			redirect_to @project
		else
			render 'new'
		end
	end
	
	def update
		@project = Project.find(params[:id])
		
		if @project.update(project_params)
			redirect_to @project
		else
			render 'edit'
		end
	end
	
	def destroy
	  @project = Project.find(params[:id])
	  @project.destroy
	 
	  redirect_to projects_path
	end
	
	def search
		
	end
	
	private
		def project_params
			params.require(:project).permit(:title,:company,:start_date,:end_date,:description, :user_id)
		end
end

