class ClustersController < ApplicationController
  def index
    clusters = CrashCluster.where(
      :year => params[:year],
      :zoom => params[:zoom].to_i,
      :lat => { '$gte' => params[:sw_lat].to_f, '$lte' => params[:ne_lat].to_f },
      :lng => { '$gte' => params[:sw_lng].to_f, '$lte' => params[:ne_lng].to_f }
    ).all
    
    respond_to do |format|
      format.html
      format.json { render :json => clusters }
    end
  end
end
