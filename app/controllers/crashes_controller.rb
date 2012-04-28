class CrashesController < ApplicationController
  def index
    crashes = Crash.where(:year => params[:year_id], :county => 62, :location => { '$exists' => true }).limit(100).all
    respond_to do |format|
      format.html
      format.json { render :json => crashes }
    end
  end
  
  def show
  end
  
  def map
  end
end
