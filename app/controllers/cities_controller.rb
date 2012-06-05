class CitiesController < ApplicationController
  def index
    crashes = CityCrash.where('_id.year' => params[:year]).all
    
    respond_to do |format|
      format.html
      format.json { render :json => crashes }
    end
  end
end