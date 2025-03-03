class SlaEventsController < ApplicationController

  before_action :authorize_global
  before_action :find_project, only: [:index, :new, :create]
  before_action :find_sla_event, only: [:edit, :update, :destroy]
  before_action :find_project_by_sla_event, only: [:edit, :update]

  def index
    @sla_events = @project ? @project.sla_events : SlaEvent.all 
    @sla_events ||= []

  end

  def new
    @sla_event = SlaEvent.new
  end

  def create
    @sla_event = SlaEvent.new(sla_event_params)
    if @sla_event.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_sla_events_path(@project)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @sla_event.update(sla_event_params)
      flash[:notice] = l(:notice_successful_update)
        redirect_to sla_events_path
    else
      render :edit
    end
  end

  def destroy
    @sla_event.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to @project.present? ? project_sla_events_path(@project) : sla_events_path
  end

  private

  def find_project_by_sla_event
    @project = @sla_event.project
  end

  def find_project
    if params[:project_id]
      @project = Project.find(params[:project_id])
    end
  end

  def find_sla_event
    @sla_event = SlaEvent.find(params[:id])
  end

  def sla_event_params
    params.require(:sla_event).permit(
      :status,
      :measured_value,
      :sla_id,
      :issue_id
    )
  end
end



