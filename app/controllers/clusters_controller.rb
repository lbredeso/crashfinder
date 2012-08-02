class ClustersController < ApplicationController
  def index
    box = [[params[:sw_lon].to_f, params[:sw_lat].to_f], [params[:ne_lon].to_f, params[:ne_lat].to_f]]
    
    clusters = CrashCluster.where(
      :year => params[:year],
      :zoom => params[:zoom].to_i,
      :location => {
        '$within' => {
          '$box' => box
        }
      }
    ).all
    
    respond_to do |format|
      format.html
      format.json { render :json => clusters }
    end
  end
end
