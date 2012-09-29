class TopController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        render json: Cluster.top(100)
      end
    end
  end
end
