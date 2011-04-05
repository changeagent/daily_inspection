require 'spec_helper'

describe Result do

  describe "checksテーブルとの関連付けのテスト" do
    context "'checks'テーブルにレコードが存在する場合" do
      subject { Factory.create(:result_has_check) }
      its(:check) { should be_instance_of Check }
    end
  end

  describe "点検基準が数値である場合に入力された点検結果(数値)から正常/異常を判断するテスト" do
    share_examples_for "result_judgment_should_be_true" do
      it {@result.judgment.should be_true}
    end

    share_examples_for "result_judgment_should_be_false" do
      it {@result.judgment.should be_false}
    end

    share_examples_for "result_judgment_should_be_nil" do
      it {@result.judgment.should be_nil}
    end

    context "入力された点検結果が下限値より小さい場合" do
      before do
        @result = Factory.build(:result_measured_value_is_smaller_than_lower_limit)
      end
      it_should_behave_like "result_judgment_should_be_false"
    end

    context "入力された点検結果が下限値と等しい場合" do
      before do
        @result = Factory.build(:result_measured_value_is_equal_lower_limit)
      end
      it_should_behave_like "result_judgment_should_be_true"
    end

    context "入力された点検結果が下限値より大きく、上限値が設定されていない場合" do
      before do
        @result = Factory.build(:result_measured_value_is_larger_than_lower_limit_withiout_upper_limit)
      end
      it_should_behave_like "result_judgment_should_be_true"
    end

    context "入力された点検結果が下限値より大きく、上限値より小さい場合" do
      before do
        @result = Factory.build(:result_measured_value_is_in_range)
      end
      it_should_behave_like "result_judgment_should_be_true"
    end

    context "入力された点検結果が上限値より小さく、下限値が設定されていない場合" do
      before do
        @result = Factory.build(:result_measured_value_is_smaller_than_upper_limit_without_lower_limit)
      end
      it_should_behave_like "result_judgment_should_be_true"
    end

    context "入力された点検結果が上限値と等しい場合" do
      before do
        @result = Factory.build(:result_measured_value_is_equal_upper_limit)
      end
      it_should_behave_like "result_judgment_should_be_true"
    end

    context "入力された点検結果が上限値より大きい場合" do
      before do
        @result = Factory.build(:result_measured_value_is_larger_than_upper_limit)
      end
      it_should_behave_like "result_judgment_should_be_false"
    end

    context "点検結果が未入力の場合" do
      before do
        @result = Factory.build(:result_measured_value_is_nil)
      end
      it_should_behave_like "result_judgment_should_be_nil"
    end

  end

  describe "点検結果、異常内容、対応・処置が正しく入力/選択されているかvalidationでチェックするテスト" do

    describe "点検結果で正常を選択した場合のテスト" do

      context "異常内容に入力した場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_0)
          @result_data = Factory.attributes_for(:result_is_selected_true_with_abnormal_content)
        end
        it "保存が成功し、異常内容は保存されないこと" do
          @check.save_result_with_validation(@result_data).should be_true
          @check.result.judgment.should == @result_data[:judgment]
          @check.result.abnormal_content.should be_nil
        end
      end

      context "対応・処置のいずれかを選択した場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_0)
          @result_data = Factory.attributes_for(:result_is_selected_true_with_corrective_action)
        end
        it "保存が成功し、対応・処置は保存されないこと" do
          @check.save_result_with_validation(@result_data).should be_true
          @check.result.judgment.should == @result_data[:judgment]
          @check.result.corrective_action.should be_nil
        end
      end
    end

    describe "点検結果で異常を選択した場合のテスト" do
      context "入力された異常内容がマルチバイトで140字以内の場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_0)
          @result_data = Factory.attributes_for(:result_is_selected_false_with_abnormal_content_under_140chars_multibyte)
        end
        it "保存が成功すること" do
          @check.save_result_with_validation(@result_data).should be_true
          @check.result.judgment.should == @result_data[:judgment]
          @check.result.abnormal_content.should == @result_data[:abnormal_content]
          @check.result.corrective_action.should == @result_data[:corrective_action]
        end
      end
      context "入力された異常内容がマルチバイトで141字以上の場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_0)
          @result_data = Factory.attributes_for(:result_is_selected_false_with_abnormal_content_over_140chars_multibyte)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
      context "入力された異常内容がシングルバイトで140字以内の場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_0)
          @result_data = Factory.attributes_for(:result_is_selected_false_with_abnormal_content_under_140chars_singlebyte)
        end
        it "保存が成功すること" do
          @check.save_result_with_validation(@result_data).should be_true
          @check.result.abnormal_content.should == @result_data[:abnormal_content]
        end
      end
      context "入力された異常内容がシングルバイトで141字以上の場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_0)
          @result_data = Factory.attributes_for(:result_is_selected_false_with_abnormal_content_over_140chars_singlebyte)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
      context "異常内容が入力されていない場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_0)
          @result_data = Factory.attributes_for(:result_is_selected_false_without_abnormal_content)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
    end

    describe "点検結果で正常/異常の選択に不備がある場合のテスト" do
      context "正常/異常を選択していない場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_0)
          @result_data = Factory.attributes_for(:result_is_not_selected_judgment)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
    end

    describe "点検結果で入力した測定値が基準範囲内(正常)である場合のテスト" do
      context "異常内容に入力した場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_true_with_abnormal_content)
        end
        it "保存が成功し、異常内容は保存されないこと" do
          @check.save_result_with_validation(@result_data).should be_true
          @check.result.judgment.should be_true
          @check.result.abnormal_content.should be_nil
        end
      end
      context "対応・処置のいずれかを選択した場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_true_with_corrective_action)
        end
        it "保存が成功し、対応・処置は保存されないこと" do
          @check.save_result_with_validation(@result_data).should be_true
          @check.result.judgment.should be_true
          @check.result.corrective_action.should be_nil
        end
      end
      context "既にあるResultsテーブルに対して基準範囲内(正常)で更新した場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_true)
          @check.save_result_with_validation(@result_data)
          @check.reload
        end
        it "更新が成功すること" do
          @result_update_data = Factory.attributes_for(:result_is_enterd_true_for_update)
          @check.save_result_with_validation(@result_update_data).should be_true
          @check.result.judgment.should be_true
        end
      end
      context "測定値の数値に小数点以下を５桁入力した場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_true_with_measured_value_over_digit)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
      context "測定値に整数部分が４桁の負の値を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy)
          @check.result.measured_value = -5555
          @result = @check.result
        end
        it "検証にパスすること" do
          @result.valid?.should be_true
        end
      end
      context "測定値に整数部分が４桁、かつ小数点以下が４桁の負の値を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy)
          @check.result.measured_value = -5555.5555
          @result = @check.result
        end
        it "検証にパスすること" do
          @result.valid?.should be_true
        end
      end
      context "測定値に'-0'を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy,
            :upper_limit => 1.1111)
          @check.result.measured_value = -0
          @result = @check.result
        end
        it "検証にパスすること" do
          @result.valid?.should be_true
        end
      end
      context "測定値に整数部分が５桁の負の値を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy)
          @check.result.measured_value = -22222
          @result = @check.result
        end
        it "検証でエラーになること" do
          @result.valid?.should be_false
        end
      end
      context "測定値に小数点以下が５桁の負の値を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy)
          @check.result.measured_value = -3333.33333
          @result = @check.result
        end
        it "検証でエラーになること" do
          @result.valid?.should be_false
        end
      end
    end

    describe "点検結果で入力した測定値が基準範囲外(異常)である場合のテスト" do
      context "入力された異常内容が140字以内の場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_false_with_abnormal_content_under_140chars_multibyte)
        end
        it "保存が成功すること" do
          @check.save_result_with_validation(@result_data).should be_true
          @check.result.judgment.should be_false
          @check.result.abnormal_content.should == @result_data[:abnormal_content]
          @check.result.corrective_action.should == @result_data[:corrective_action]
        end
      end
      context "入力された異常内容が141字以上の場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_false_with_abnormal_content_over_140chars_singlebyte)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
      context "異常内容が入力されていない場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_false_without_abnormal_content)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
      context "既にあるResultsテーブルに対して基準範囲外(正常)かつ異常内容を入力せずに更新した場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_true)
          @check.save_result_with_validation(@result_data)
          @check.reload
        end
        it "更新が失敗すること" do
          @result_update_data = Factory.attributes_for(:result_is_enterd_false_without_abnormal_content)
          @check.save_result_with_validation(@result_update_data).should be_false
        end
      end
      context "測定値に整数部分が４桁の負の値（上限値より大きい）を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy)
          @check.result.measured_value = -1111
          @result = @check.result
        end
        it "検証でエラーになること" do
          @result.valid?.should be_false
        end
      end
      context "測定値に整数部分が４桁の負の値（下限値より小さい）を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy)
          @check.result.measured_value = -9999
          @result = @check.result
        end
        it "検証でエラーになること" do
          @result.valid?.should be_false
        end
      end
      context "測定値に小数点以下が４桁の負の値（上限値より大きい）を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy)
          @check.result.measured_value = -1111.1111
          @result = @check.result
        end
        it "検証でエラーになること" do
          @result.valid?.should be_false
        end
      end
      context "測定値に小数点以下が４桁の負の値（下限値より小さい）を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_dummy)
          @check.result.measured_value = -9999.9999
          @result = @check.result
        end
        it "検証でエラーになること" do
          @result.valid?.should be_false
        end
      end
    end

    describe "点検結果で測定値の入力に不備がある場合のテスト" do
      context "測定値を入力していない場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_not_enterd_measured_value)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
      context "測定値に数値以外を入力した場合" do
        before do
          @check = Factory.create(:check_has_result_with_entry_type_1)
          @result_data = Factory.attributes_for(:result_is_enterd_character_into_measured_value)
        end
        it "保存が失敗すること" do
          @check.save_result_with_validation(@result_data).should be_false
        end
      end
    end
  end

  describe "対応者氏名コードを更新するテスト" do
    before do
      @inspection = Factory.create(:inspection_has_normal_check_for_set_staff_code)
      @check_master = Factory.create(:check_has_normal_cycle_for_set_staff_code)
      @inspection.checks[0] = Factory.create(:check_is_normal_for_set_staff_code,:parent_id => @check_master.id, :inspection_id => @inspection.id)
    end
    context "対応日時が入っている場合" do
      before do
        @inspection.checks[0].save_result_with_validation({:judgment => false,
            :abnormal_content => "異常です。", :corrective_action => 0, :corrected_datetime => DateTime.now})
        @check = @inspection.checks[0]
        @result_updated_at = @check.result.updated_at
      end
      it "対応者氏名コードが更新されること" do
        sleep 1   # 更新日付を比較するため１秒待機
        @check.result.set_staff_code!.should be_true
        @check.result.staff_code.should == @inspection.staff_code
        @check.result.updated_at.to_s.should > @result_updated_at.to_s
      end
    end
    context "対応日時は入っているが例外が発生する場合" do
      before do
        @inspection.checks[0].save_result_with_validation({:judgment => false,
            :corrective_action => 0, :corrected_datetime => DateTime.now}, false)
        @check = @inspection.checks[0]
        @result_updated_at = @check.result.updated_at
      end
      it "対応者氏名コードが更新されないこと" do
        sleep 1   # 更新日付を比較するため１秒待機
        lambda{@check.result.set_staff_code!}.should raise_error(ActiveRecord::RecordInvalid)
        @check.reload
        @check.result.staff_code.should be_nil
        @check.result.updated_at.to_s.should == @result_updated_at.to_s
      end
    end
    context "対応日時が入っていない場合" do
      before do
        @inspection.checks[0].save_result_with_validation({:judgment => true})
        @check = @inspection.checks[0]
        @result_updated_at = @check.result.updated_at
      end
      it "対応者氏名コードが更新されないこと" do
        sleep 1   # 更新日付を比較するため１秒待機
        @check.result.set_staff_code!.should be_nil
        @check.result.staff_code.should be_nil
        @check.result.updated_at.to_s.should == @result_updated_at.to_s
      end
    end
  end

  describe "点検日時と対応日時の値を保存するテスト" do
    before do
      @result = Factory.create(:check_has_result_with_checked_datetime_and_corrected_datetime).result
      @latest_checked_datetime = @result.checked_datetime
      @latest_corrected_datetime = @result.corrected_datetime
    end

    share_examples_for "checked_datetime_and_corrected_datetime_should_not_be_updated_without_validation" do
      it "点検日時と対応日時が更新されていないこと" do
        @result.save_with_validation(false).should be_true
        @result.checked_datetime.should == @latest_checked_datetime
        @result.corrected_datetime.should == @latest_corrected_datetime
      end
    end

    share_examples_for "checked_datetime_and_corrected_datetime_should_be_updated_with_validation" do
      it "点検日時と対応日時が更新されていること" do
        @result.save_with_validation(true).should be_true
        @result.checked_datetime.to_s.should == DateTime.parse(@result.updated_at.to_s).to_s
        @result.corrected_datetime.to_s.should == DateTime.parse(@result.updated_at.to_s).to_s
      end
    end

    share_examples_for "checked_datetime_should_be_updated_and_corrected_datetime_should_be_nil_with_validation" do
      it "点検日時が更新され、対応日時がnilであること" do
        @result.save_with_validation(true).should be_true
        @result.checked_datetime.to_s.should == DateTime.parse(@result.updated_at.to_s).to_s
        @result.corrected_datetime.should == nil
      end
    end

    context "validationなしで保存する場合" do
      before do
        @result.attributes = {:judgment => false, :corrective_action => 1}
      end

      it_should_behave_like "checked_datetime_and_corrected_datetime_should_not_be_updated_without_validation"
    end

    context "validationありで保存する場合" do
      context "点検結果が異常かつ対応・処置が選択されている場合" do
        before do
          @result.attributes = {:judgment => false, :corrective_action => 1}
        end

        it_should_behave_like "checked_datetime_and_corrected_datetime_should_be_updated_with_validation"
      end

      context "点検結果が異常かつ対応・処置が選択されていない場合" do
        before do
          @result.attributes = {:judgment => false, :corrective_action => nil}
        end

        it_should_behave_like "checked_datetime_should_be_updated_and_corrected_datetime_should_be_nil_with_validation"
      end

      context "点検結果が正常かつ対応・処置が選択されている場合" do
        before do
          @result.attributes = {:judgment => true, :abnormal_content => nil, :corrective_action => 1}
        end

        it_should_behave_like "checked_datetime_should_be_updated_and_corrected_datetime_should_be_nil_with_validation"
      end

      context "点検結果が正常かつ対応・処置が選択されていない場合" do
        before do
          @result.attributes = {:judgment => true, :abnormal_content => nil, :corrective_action => nil}
        end

        it_should_behave_like "checked_datetime_should_be_updated_and_corrected_datetime_should_be_nil_with_validation"
      end
    end
  end
  describe "'対応内容'を更新する際の入力チェック機能" do
    before do
      @result = Factory.create(:result_for_validation_check_before_update_correction)
      @attributes = {:abnormal_content => "異常内容テキスト",
                     :staff_code => "0123456",
                     :corrected_datetime => "2010/12/13 12:34:56",
                     :corrective_action => Result::CORRECTIVE_ACTION_VALUES["EXCHANGE"],
                     :corrective_content => "対応内容テキスト"}
    end
    context "パラメータが正しくセットされた場合" do
      before do
        @ret = @result.update_correction(@attributes)
      end
      it "'update_correction'メソッドがtrueを返却すること" do
        @ret.should be_true
      end
      it "'results'テーブルのレコードが更新されること" do
        result = Result.find(@result.id)
        result.abnormal_content.should == @attributes[:abnormal_content]
        result.staff_code.should == @attributes[:staff_code]
        result.corrected_datetime.should == Time.parse(@attributes[:corrected_datetime])
        result.corrective_action.should == @attributes[:corrective_action]
      end
    end
    context "パラメータが正しくセットされなかった場合" do
      context "いずれかのパラメータが未入力の場合" do
        it "'update_correction'メソッドがfalseを返却し、エラーメッセージを取得できること" do
          @attributes.each_key do |key|
            case key.to_sym
            when :abnormal_content, :staff_code, :corrected_datetime, :corrective_content
              @attributes[key] = ""
              @result.update_correction(@attributes).should be_false
              @result.errors.full_messages.should include(I18n.t("activerecord.attributes.result.#{key.to_s}") + 
                                                          I18n.t("activerecord.errors.messages.blank"))
            when :corrective_action
              @attributes.delete(key)
              @result.update_correction(@attributes).should be_false
              @result.errors.full_messages.should include(I18n.t("activerecord.attributes.result.#{key.to_s}") + 
                                                          I18n.t("activerecord.errors.messages.not_selected"))
            end
            Result.find(@result.id).updated_at.to_s.should == @result.updated_at.to_s
          end
        end
      end
      share_examples_for "update_correction_should_return_false_and_error_messages_are_setted" do
        it "'update_correction'メソッドがfalseを返し、エラーメッセージがセットされること" do
          @result.update_correction(@attributes).should be_false
          @result.errors.full_messages.should include(@message)
        end
      end
      share_examples_for "result_record_does_not_updated" do
        it "Resultデータが更新されないこと" do
          Result.find(@result.id).updated_at.to_s.should == @result.updated_at.to_s
        end
      end
      context "異常内容または対応内容が140文字以内でない場合" do
        [:abnormal_content, :corrective_content].each do |attr_sym|
          ["a", "あ"].each do |char|
            before do
              @attributes[attr_sym] = 141.times.collect{char}.to_s
              @message = I18n.t("activerecord.attributes.result.#{attr_sym.to_s}") + I18n.t("activerecord.errors.messages.too_long", :count => 140)
            end
            it_should_behave_like "update_correction_should_return_false_and_error_messages_are_setted"
            it_should_behave_like "result_record_does_not_updated"
          end
        end
      end
      context "対応者氏名コードが半角英数7文字でない場合" do
        ["666666", "eight888", "chk000-", "777777７"].each do |invalid_staff_code|
          before do
            @attributes[:staff_code] = invalid_staff_code
            @message = I18n.t("activerecord.attributes.result.staff_code") + I18n.t("activerecord.errors.messages.wrong_length_with_half_width_char_and_num", :count => 7)
          end
          it_should_behave_like "update_correction_should_return_false_and_error_messages_are_setted"
          it_should_behave_like "result_record_does_not_updated"
        end
      end
      context "対応日時の形式が、YYYY/MM/DD HH:MM:SSでない場合" do
        ["2010/12/13", "12:30:40" "2010/12/32 12:34:56", "2010/12/13 -8:12:34", "2010/12/13 am/12/34", "2010/12/13 24:00:00", "2010/12/13 00:60:00", "2010/12/13 00:00:61"].each do |invalid_datetime|
          before do
            @attributes[:corrected_datetime] = invalid_datetime
            @message = I18n.t("activerecord.errors.models.result.corrected_date_format_was_invalid")
          end
          it_should_behave_like "update_correction_should_return_false_and_error_messages_are_setted"
          it_should_behave_like "result_record_does_not_updated"
        end
      end
    end
  end
end
