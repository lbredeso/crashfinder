class ClustersController < ApplicationController
  def index    
    respond_to do |format|
      format.html
      format.json do
        clusters = Cluster.
          by_year(params[:year]).
          at_zoom(params[:zoom].to_i).
          within(params[:sw_lat].to_f, params[:ne_lat].to_f, params[:sw_lng].to_f, params[:ne_lng].to_f)
        render json: clusters
      end
    end
  end
end
