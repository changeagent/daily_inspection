# 工程、設備を扱うコントローラ。
class StationsController < ApplicationController
  before_filter :find_station_included_equipment

  # 工程、設備を表示するアクション(オペレータ用)
  def operator_index
  end

  # 工程、設備を表示するアクション(職制用)
  def ladder_index
    render :layout => 'pc'
  end

  private
  # 工程名と工程に関連付けられた設備を取得する
  def find_station_included_equipment
    @stations = Station.all
    unless params[:id].nil? && session[:station_id].nil?
      params[:id] ||= session[:station_id]
      @station = Station.find(:first, :include => [:equipment], :conditions => ['stations.id = ?', params[:id]])
      session[:station_id] = @station.id unless @station.nil?
    end
  end
end
