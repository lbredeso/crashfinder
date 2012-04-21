class CrashesController < ApplicationController
  def index
  end
  
  def show
  end
  
  def map
    crashes = Crash.where(:year => '2010', :county => 62, :location => { '$exists' => true }).limit(100).all
    respond_to do |format|
      format.html
      format.json { render :json => crashes }
    end
  end
end
