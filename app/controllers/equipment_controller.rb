# 設備毎の点検データを扱うコントローラ。
class EquipmentController < ApplicationController

  # 設備の点検一覧を表示するアクション。
  def show_scheduled_checks
    session[:start_datetime] = DateTime.now
    @scheduled_checks = Equipment.scheduled_checks(params[:id], session[:start_datetime])
    if @scheduled_checks.size == 0
      flash[:message] = t('errors.controllers.equipment.show_scheduled_checks.does_not_found')
      redirect_to :controller => 'stations', :action => 'operator_index'
    end
  end

  # 設備の点検結果一覧を表示するアクション。
  def show_list_of_result
    @today = DateTime.now
    @checks = Equipment.list_of_result(params[:id], @today)
    unless @checks.size == 0
      render :layout => 'pc'
    else
      flash[:message] = t('errors.controllers.equipment.show_list_of_result.does_not_found')
      redirect_to :controller => 'stations', :action => 'ladder_index'
    end
  end

  # 点検を開始するアクション。
  def start_inspection
    first_check_id = Equipment.start_inspection(params[:id], session[:start_datetime])
    # MEMO: 現状のユーザストーリーには、点検が開始できない場合は想定されていない。別ユーザストーリで検討する予定。
    # redirect_to :action => 'show_scheduled_checks', :id => params[:id] if first_check_id.nil?
    redirect_to :controller => 'checks', :action => 'show', :id => first_check_id
  end
end