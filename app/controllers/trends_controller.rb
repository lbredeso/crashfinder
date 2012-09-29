class TrendsController < ApplicationController
  before_filter :require_login
  
  def index
    @locations = current_user.locations
  end
  
  def yearly
    @year_stats = YearStat.by_user(current_user).in_order.all
    respond_to do |format|
      format.json do
        render json: @year_stats
      end
    end
  end
  
  def monthly
    @month_stats = MonthStat.by_user(current_user).in_order.all
    respond_to do |format|
      format.json do
        render json: @month_stats
      end
    end
  end
end
