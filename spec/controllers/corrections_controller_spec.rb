require 'spec_helper'

describe CorrectionsController do

  describe "'show/:id'アクションのテスト" do
    before do
      @check = Factory.create(:check_has_result_and_inspection)
      @check.save_result_with_validation({:judgment => false}, false)
      get 'show', :id => @check.id
    end

    it "checkデータが取得できること" do
      assigns[:check].should be_instance_of Check
      assigns[:check].should == @check
    end

    it { response.should be_success }
    it { response.layout.should == "layouts/pc" }
    it { response.should render_template("corrections/show") }
  end

  describe "updateアクションのテスト" do
    context "正常に更新できる場合" do
      before do
        @check = Factory.create(:check_has_result_and_inspection)
        @check.save_result_with_validation({:judgment => false, :abnormal_content => "部品Bが異常です。"}, false)
        @correction = {:abnormal_content => "部品Ａが異常です。",
          :corrective_action => 0,
          :corrective_content => "部品Ａを交換しました。",
          :staff_code => "staff01",
          :corrected_datetime => "2010/12/15 12:34:56"}
        post 'update', :id => @check.id, :correction => @correction
      end
      it { response.should be_redirect }

      it "checkデータが取得できること" do
        assigns[:check].should be_instance_of Check
        assigns[:check].should == @check
      end

      it "更新が成功すること" do
        result = assigns[:check].result
        result.abnormal_content.should == @correction[:abnormal_content]
        result.corrective_action.should == @correction[:corrective_action]
        result.corrective_content.should == @correction[:corrective_content]
        result.staff_code.should == @correction[:staff_code]
        result.corrected_datetime.should == Time.parse(@correction[:corrected_datetime])
      end
      
      it "点検結果一覧画面に遷移されること" do
        response.should redirect_to(:controller => 'equipment', :action => 'show_list_of_result', :id => @check.part.equipment_id)
      end
    end

    context "正常に更新できない場合" do
      before do
        @check = Factory.create(:check_has_result_and_inspection)
        @check.save_result_with_validation({:judgment => false, :abnormal_content => "部品Bが異常です。"}, false)
        @correction = {:abnormal_content => "",
          :corrective_action => 0,
          :corrective_content => "部品Ａを交換しました。",
          :staff_code => "staff01",
          :corrected_datetime => "2010/12/15 12:34:56"}
        post 'update', :id => @check.id, :correction => @correction
      end
      it { response.should be_success }

      it "checkデータが取得できること" do
        assigns[:check].should be_instance_of Check
        assigns[:check].should == @check
      end

      it "更新されていないこと" do
        Result.count(:conditions => ['id=? AND abnormal_content=? AND corrective_action=? AND corrective_content=? AND staff_code=? AND corrected_datetime=?',
            @check.result.id, @correction[:abnormal_content], @correction[:corrective_action], @correction[:corrective_content],
            @correction[:staff_code], @correction[:corrected_datetime]]).should == 0
      end

      it "異常対応確認入力画面に遷移されること" do
        response.flash[:message].should == assigns[:check].result.errors.full_messages.join('\n')
        response.layout.should == "layouts/pc"
        response.should render_template("corrections/show/")
      end
    end
  end

end
