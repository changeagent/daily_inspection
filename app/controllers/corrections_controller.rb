# 点検結果が異常だった場合の対応を扱うコントローラー
class CorrectionsController < ApplicationController

  # 異常対応確認入力画面を表示するアクション
  def show
    @check = Check.find_with_inspection_and_result_and_part(params[:id])
    render :layout => 'pc'
  end

  # 異常対応内容を更新するアクション
  def update
    @check = Check.find(params[:id])
    if @check.result.update_correction(params[:correction])
      redirect_to :controller => 'equipment', :action => 'show_list_of_result', :id => @check.part.equipment_id
    else
      flash.now[:message] = @check.result.errors.full_messages.join('\n')
      render :controller => 'corrections', :action => 'show', :id => @check.id, :layout => 'pc'
    end
  end

end
