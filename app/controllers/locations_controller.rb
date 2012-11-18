class LocationsController < ApplicationController
  before_filter :require_login
  
  def index
    @locations = current_user.locations
    respond_to do |format|
      format.html
      format.json do
        render json: @locations
      end
    end
  end
  
  def show
    @location = Location.find params[:id]
    respond_to do |format|
      format.json do
        render json: @location
      end
    end
  end
  
  def create
    @location = Location.new params[:location]
    @location.user = current_user
    @location.save
    respond_to do |format|
      format.json do
        render json: @location
      end
    end
  end
  
  def update
    @location = Location.find params[:id]
    @location.update_attributes params[:location]
    respond_to do |format|
      format.json do
        render json: @location
      end
    end
  end
  
  def destroy
    @location = Location.find params[:id]
    @location.destroy
    respond_to do |format|
      format.json do
        render json: {}
      end
    end
  end
end
