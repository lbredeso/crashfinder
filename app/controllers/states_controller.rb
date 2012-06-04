class StatesController < ApplicationController
  def index
    crashes = StateCrash.where('_id.year' => params[:year]).all
    
    respond_to do |format|
      format.html
      format.json { render :json => crashes }
    end
  end
end