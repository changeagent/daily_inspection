# 点検内容、点検結果を扱うコントローラ。
class ChecksController < ApplicationController

  # 点検内容と点検結果入力欄を表示するアクション。
  def show
    @check = Check.find params[:id]
    @result = @check.result || Result.new(:check_id => @check.id)
  end

  # 点検結果を保存し、次の点検に進むアクション。
  def next
    @check = Check.find(params[:id])
    if @check.save_result_with_validation(params[:result])
      unless @check.last?
        redirect_to :action => 'show', :id => @check.next_check.id
      else
        redirect_to :controller => 'inspections', :action => 'final_confirm', :id => @check.inspection_id
      end
    else
      @result = @check.result
      flash.now[:message] = @result.errors.full_messages.join('\n')
      render :action => 'show'
    end
  end

  # 点検結果を保存し、前の点検に戻るアクション。
  def previous
    @check = Check.find(params[:id])
    @check.save_result_with_validation(params[:result], false)
    unless @check.first?
      redirect_to :action => 'show', :id => @check.previous_check.id
    else
      redirect_to "/"
    end
  end
end
