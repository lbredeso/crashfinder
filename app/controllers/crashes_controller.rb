class CrashesController < ApplicationController
  def index
    box = [[params[:sw_lon].to_f, params[:sw_lat].to_f], [params[:ne_lon].to_f, params[:ne_lat].to_f]]
    
    crashes = Crash.where(
      :year => params[:year],
      :location => {
        '$within' => {
          '$box' => box
        }
      }
    ).all
    
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
