require 'spec_helper'

describe Inspection do
  describe "点検結果（スタッフコード）の保存テスト" do
    context "点検結果に不備がない場合" do
      before do
        @inspection_for_valid_result_data = Factory.create(:inspection_valid_result_data)
        Check.destroy_all(:inspection_id => @inspection_for_valid_result_data.id)
        check = Factory.create(:check_has_valid_result_judgment_false)
        check.save_result_with_validation({:judgment => true}, false)
        check.update_attributes(:inspection_id => @inspection_for_valid_result_data.id)
      end

      it "7文字より短いスタッフコードは保存できないこと" do
        @inspection_for_valid_result_data.update_attributes(:staff_code => "staff").should be_false
      end

      it "7文字より長いスタッフコードは保存できないこと" do
        @inspection_for_valid_result_data.update_attributes(:staff_code => "staff001").should be_false
      end

      it "ブランクのスタッフコードは保存できないこと" do
        @inspection_for_valid_result_data.update_attributes(:staff_code => "").should be_false
      end

      it "英数字以外の文字が使用されているスタッフコードは保存できなこと" do
        @inspection_for_valid_result_data.update_attributes(:staff_code => "staf0@_").should be_false
      end

      it "半角英数7文字のスタッフコードは保存できること" do
        @inspection_for_valid_result_data.update_attributes(:staff_code => "staff01").should be_true
      end
    end

    context "点検結果に不備がある場合" do
      it "適切でない点検結果データ保存されている場合は、スタッフコードを保存できないこと" do
        check = Factory.create(:check_has_invalid_result)
        check.save_result_with_validation({:measured_value => 30.0}, false)
        inspection = Inspection.find(check.inspection_id)
        inspection.update_attributes(:staff_code => "staff01").should be_false
        inspection.errors.full_messages.should include("1" + I18n.t("activerecord.errors.models.inspection.check_result_was_invalid"))
      end

      it "未点検の点検内容がある場合は、スタッフコードを保存できないこと" do
        inspection = Inspection.find(Factory.create(:check_has_not_been_checked).inspection_id)
        inspection.update_attributes(:staff_code => "staff01").should be_false
        inspection.errors.full_messages.should include("1" + I18n.t("activerecord.errors.models.inspection.has_not_been_checked"))
      end
    end
  end

  describe "checksテーブルとの関連付けのテスト" do
    context "'checks'テーブルにレコードが存在する場合" do
      before do
        @inspection = Factory.create(:inspection_has_checks)
      end
      it "checksメソッドでcheckインスタンスを要素にもつ配列を取得すること" do
        @inspection.checks.should have(2).items
        @inspection.checks[0].should be_instance_of Check
        @inspection.checks[1].should be_instance_of Check
      end
    end
    context "'checks'テーブルにレコードが存在しない場合" do
      before do
        @inspection = Factory.create(:inspection_does_not_have_check)
      end
      it "checksメソッドで空の配列を取得すること" do
        @inspection.checks.should have(0).items
        @inspection.checks[0].should be_nil
      end
    end
  end

  describe "点検結果を保存するテスト" do
    context "スタッフコード及び点検予定日を更新できる場合" do
      before do
        @check = Factory.create(:check_has_normal_cycle)
        @check_updated_at = @check.updated_at
        @inspection = Factory.create(:inspection_has_normal_checks)
        @inspection_update_at = @inspection.updated_at

        @inspection.checks[0] = Factory.create(:check_is_normal1, :parent_id => @check.id, :inspection_id => @inspection.id)
        @inspection.checks[0].save_result_with_validation({:judgment => true})
        @check1_updated_at = @inspection.checks[0].updated_at

        @inspection.checks[1] = Factory.create(:check_is_normal2, :parent_id => @check.id, :inspection_id => @inspection.id)
        @inspection.checks[1].save_result_with_validation({:judgment => true})
        @check2_updated_at = @inspection.checks[1].updated_at
      end
      it "更新日時が更新されていること" do
        @inspection.finish({:staff_code => "staff01"}).should be_true
        @inspection.reload
        @inspection.updated_at.to_datetime.should > @inspection_update_at
        @check.reload
        @check.updated_at.to_datetime.should > @check_updated_at.to_datetime
      end
    end

    context "スタッフコードを更新できない場合" do
      before do
        @check = Factory.create(:check_has_normal_cycle)
        @check_updated_at = @check.updated_at
        @inspection = Factory.create(:inspection_has_normal_checks)
        @inspection_update_at = @inspection.updated_at

        @inspection.checks[0] = Factory.create(:check_is_normal1, :parent_id => @check.id, :inspection_id => @inspection.id)
        @inspection.checks[0].save_result_with_validation({:judgment => true})
        @check1_updated_at = @inspection.checks[0].updated_at

        @inspection.checks[1] = Factory.create(:check_is_normal2, :parent_id => @check.id, :inspection_id => @inspection.id)
        @inspection.checks[1].save_result_with_validation({:judgment => true})
        @check2_updated_at = @inspection.checks[1].updated_at
      end
      it "更新日時が更新されていないこと" do
        @inspection.finish({:staff_code => "bad"}).should be_false
        @inspection.reload
        @inspection.updated_at.to_datetime.should === @inspection_update_at
        @check.reload
        @check.updated_at.to_datetime.should === @check_updated_at.to_datetime
      end
    end

    context "点検予定日を更新できない場合" do
      before do
        @check = Factory.create(:check_has_abnormal_cycle)
        @check_updated_at = @check.updated_at
        @inspection = Factory.create(:inspection_has_abnormal_checks)
        @inspection_update_at = @inspection.updated_at

        @inspection.checks[0] = Factory.create(:check_is_abnormal1, :parent_id => @check.id, :inspection_id => @inspection.id)
        @inspection.checks[0].save_result_with_validation({:judgment => true})
        @check1_updated_at = @inspection.checks[0].updated_at

        @inspection.checks[1] = Factory.create(:check_is_abnormal2, :parent_id => @check.id, :inspection_id => @inspection.id)
        @inspection.checks[1].save_result_with_validation({:judgment => true})
        @check2_updated_at = @inspection.checks[1].updated_at
      end
      it "更新日時が更新されていないこと" do
        @inspection.finish({:staff_code => "staff02"}).should be_false
        @inspection.reload
        @inspection.updated_at.to_datetime.should === @inspection_update_at
        @check.reload
        @check.updated_at.to_datetime.should === @check_updated_at.to_datetime
      end
    end
  end

  describe "対応者氏名コードを更新するテスト" do
    before do
      @check = Factory.create(:check_has_normal_cycle)
      @inspection = Factory.create(:inspection_has_normal_checks)
      @inspection_staff_code = "staff01"
      @inspection.checks[0] = Factory.create(:check_is_normal1,:parent_id => @check.id, :inspection_id => @inspection.id)
    end
    context "対応日時が入っている場合" do
      before do
        @inspection.checks[0].save_result_with_validation({:judgment => false,
            :abnormal_content => "異常です。", :corrective_action => 0, :corrected_datetime => DateTime.now})
        @result = @inspection.checks[0].result
        @result_updated_at = @result.updated_at
      end
      it "対応者氏名コードが保存されること" do
        sleep 1   # 更新日付を比較するため１秒待機
        @inspection.finish({:staff_code => @inspection_staff_code}).should be_true
        @result.staff_code.should == @inspection_staff_code
        @result.updated_at.to_s.should > @result_updated_at.to_s
      end
    end
    context "対応日時が入っていない場合" do
      before do
        @inspection.checks[0].save_result_with_validation({:judgment => true})
        @result = @inspection.checks[0].result
        @result_updated_at = @result.updated_at
      end
      it "対応者氏名コードが保存されないこと" do
        sleep 1   # 更新日付を比較するため１秒待機
        @inspection.finish({:staff_code => @inspection_staff_code}).should be_true
        @result.staff_code.should be_nil
        @result.updated_at.to_s.should == @result_updated_at.to_s
      end
    end
  end

end
