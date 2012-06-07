class CitiesController < ApplicationController
  def index
    box = [[params[:sw_lon].to_f, params[:sw_lat].to_f], [params[:ne_lon].to_f, params[:ne_lat].to_f]]
    
    crashes = CityCrash.where(
      '_id.year' => params[:year],
      'value.location' => {
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
end