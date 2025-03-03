class AssessmentsController < ApplicationController

    before_action :authorize_global
    before_action :find_project, only: [:index, :new, :create]
    before_action :find_assessment, only: [:edit, :update, :destroy]
    before_action :find_project_by_assessment, only: [:edit, :update]

    
    
    def index
        @assessments = @project ? @project.assessments : Assessment.all 
        @assessments ||= []
    end
    
    def new
       @assessment = Assessment.new
    end
       
    def create
        @assessment = Assessment.new(assessment_params)
            if @assessment.save
            flash[:notice] = l(:notice_successful_create)
            redirect_to project_assessments_path(@project)
        else
            render :new
        end
    end

    def edit
    end

    def update
        if @assessment.update(assessment_params)
            flash[:notice] = l(:notice_successful_update)
            redirect_to assessments_path
        else
            render :edit
        end
    end

    def destroy
        @assessment.destroy
        flash[:notice] = l(:notice_successful_delete)
        redirect_to @project.present? ? project_assessment_path(@project) : assessments_path
    end

    def update_by_issue
        @issue = Issue.find(params[:issue_id])
        @assessments = @issue.assessments 
        if update_assessments 
            flash[:notice] = l(:notice_successful_update) 
            redirect_to issue_path(@issue, :tab => 'assessments') 
        else 
            render :edit
        end
    end
       
    
    private

    def update_assessments
        params[:issue][:assessments].each do |id, attributes|
            assessment = Assessment.find(id)
            unless assessment.update(attributes.permit(:attendance, :technical_expertise, :conduct))
                return false 
            end 
        end 
        true
    end

    def find_project_by_assessment
        @project = @assessment.project
    end
  
    def find_project
        if params[:project_id]
          @project = Project.find(params[:project_id])
        end
    end

    def find_assessment 
        @assessment = Assessment.find(params[:id])
    end

    def assessment_params
        params.require(:assessment).permit(
            :sla_event_id,
            :user_id, 
            :attendance, 
            :technical_expertise, 
            :conduct
        )
    end

end
  