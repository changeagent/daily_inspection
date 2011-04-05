require 'spec_helper'

describe InspectionsController do
  share_examples_for "should be render to template 'inspections/final_confirm'" do
    it { response.should render_template("inspections/final_confirm") }
  end

  describe "'final_confirm/:id'アクションのテスト" do
    context "inspectionデータを表示する場合" do
      before do
        @inspection = Factory.create(:inspection_has_check)
        @check = Factory.create(:check_belong_to_inspection, :inspection_id => @inspection.id)
        get 'final_confirm', :id => @check.inspection_id
      end

      it { response.should be_success }

      it "inspectionデータが取得できること" do
        assigns[:inspection].should == @inspection
      end

      it "取得したinspectionデータは、inspectionモデルのインスタンスであること" do
        assigns[:inspection].should be_instance_of Inspection
      end

      it_should_behave_like "should be render to template 'inspections/final_confirm'"
    end
  end

  describe "updateアクションのテスト" do
    share_examples_for "inspection_instance_shuld_not_be_assigned" do
      it "インスタンス変数inspectionに、@inspection_for_valid_resultの値がセットされること" do
        assigns[:inspection].should == @inspection_for_result
      end
    end

    share_examples_for "inspection_data_shuld_not_be_updated" do
      it "点検が更新されていないこと" do
        Inspection.count(:conditions => ['id=? and staff_code=?',
            @inspection_for_result.id,
            @staff_code]).should == 0
      end
    end

    share_examples_for "should_be_render_template_inspection/final_confirm" do
      it "ステータスコード200が返却されること" do
        response.should be_success
      end
      it "最終確認画面が表示されること" do
        response.should render_template("inspections/final_confirm")
      end
    end

    before do
      check = Factory.create(:check_has_valid_result)
      @inspection_for_result = Factory.create(:inspection_for_update_action)
      @inspection_for_result.checks[0] =
        Factory.create(:check_is_normal, :parent_id => check.id, :inspection_id => @inspection_for_result.id)
      @inspection_for_result.checks[0].save_result_with_validation(:judgment => true)
    end

    # @inspection.finish()がtrueの場合
    # (inspectionが保存でき、checkの次回点検日時が更新できる場合)
    context "適切な点検結果・適切な氏名コードの場合" do
      before do
        @station_id = session[:station_id] = Factory.create(:station_for_inspection_update_action).id
        @staff_code = "staff01"
        post 'update', :id => @inspection_for_result.id, :inspection => {:staff_code => @staff_code}
      end
      
      it "点検が更新されていること" do
        Inspection.count(:conditions => ['id=? and staff_code=?',
            @inspection_for_result.id, @staff_code]).should == 1
      end

      it "日常点検メニュー画面にリダイレクトされること" do
        session[:station_id].should == @station_id
        session[:staff_code].should == @staff_code
        response.should redirect_to(:controller => 'stations', :action => 'operator_index')
      end
    end

    # @inspection.finish()がfalseの場合
    # (inspectionが保存できない場合)
    context "適切な点検結果・適切でない氏名コードの場合" do
      before do
        @staff_code = "staff"
        post 'update', :id => @inspection_for_result.id, :inspection => {:staff_code => @staff_code}
      end

      it_should_behave_like "inspection_instance_shuld_not_be_assigned"
      it_should_behave_like "inspection_data_shuld_not_be_updated"
      it_should_behave_like "should_be_render_template_inspection/final_confirm"
    end
  end
end
