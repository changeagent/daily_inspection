# 点検者氏名コードを入力し、全点検結果を保存するコントローラ。
class InspectionsController < ApplicationController
  # 点検者氏名コードを入力する画面を表示するアクション。
  def final_confirm
    @inspection = Inspection.find(params[:id])
  end

  # 点検を保存するアクション。
  def update
    @inspection = Inspection.find(params[:id])
    if @inspection.finish(params[:inspection])
      session[:staff_code] = params[:inspection][:staff_code]
      redirect_to :controller => 'stations', :action => 'operator_index'
    else
      flash.now[:message] = @inspection.errors.full_messages.join('\n')
      render :action => 'final_confirm'
    end
  end
end
