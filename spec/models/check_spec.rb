require 'spec_helper'

describe Check do

  describe "partsテーブルとの関連付けのテスト" do
    context "'parts'テーブルにレコードが存在する場合" do
      subject { Factory.create(:check_has_part) }
      its(:part) { should be_instance_of Part }
    end
    context "'parts'テーブルにレコードが存在しない場合" do
      subject { Factory.create(:check_does_not_have_part) }
      its(:part) { should be_nil }
    end
  end

  describe "resultsテーブルとの関連付けのテスト" do
    context "'results'テーブルにレコードが存在する場合" do
      subject { Factory.create(:check_has_result) }
      its(:result) { should be_instance_of Result }
    end
    context "'results'テーブルにレコードが存在しない場合" do
      subject { Factory.create(:check_does_not_have_result) }
      its(:result) { should be_nil }
    end
  end

  describe "連続する点検内容の振る舞いテスト" do
    before(:all) do
      inspection_id = Check.maximum(:inspection_id).to_i + 1
      @sequential_checks = {:first => Factory.create(:check_of_sequentially,
          :inspection_id => inspection_id),
        :middle => Factory.create(:check_of_sequentially,
          :inspection_id => inspection_id),
        :last => Factory.create(:check_of_sequentially,
          :inspection_id => inspection_id)}
    end

    after(:all) do
      @sequential_checks.each_value {|check|check.destroy}
    end

    it "next_checkメソッドは次の点検内容を返すこと" do
      @sequential_checks[:first].next_check.should == @sequential_checks[:middle]
      @sequential_checks[:middle].next_check.should == @sequential_checks[:last]
      @sequential_checks[:last].next_check.should be_nil
    end

    it "previous_checkメソッドは前の点検内容を返すこと" do
      @sequential_checks[:first].previous_check.should be_nil
      @sequential_checks[:middle].previous_check.should == @sequential_checks[:first]
      @sequential_checks[:last].previous_check.should == @sequential_checks[:middle]
    end

    it "first?メソッドは最初のcheckに対してのみtrueを返すこと" do
      @sequential_checks[:first].first?.should be_true
      @sequential_checks[:middle].first?.should be_false
      @sequential_checks[:last].first?.should be_false
    end

    it "last?メソッドは最後のcheckに対してのみtrueを返すこと" do
      @sequential_checks[:first].last?.should be_false
      @sequential_checks[:middle].last?.should be_false
      @sequential_checks[:last].last?.should be_true
    end
  end

  describe "点検基準値を表現する文字列を取得する'limit_description'のテスト" do
    before do
      @upper_limit = 10.0
      @lower_limit = 1.0
      @unit_name = "hpa"
    end
    context '上限値と下限値が設定されている場合' do
      subject {Factory.create(:check_specified_limit,
          :upper_limit => @upper_limit,
          :lower_limit => @lower_limit,
          :unit_name => @unit_name)}
      its(:limit_description) { should == "#{@lower_limit} ～ #{@upper_limit} #{@unit_name}" }
    end

    context '上限値のみが設定されている場合' do
      subject {Factory.create(:check_specified_limit,
          :upper_limit => @upper_limit,
          :lower_limit => nil,
          :unit_name => @unit_name)}
      its(:limit_description) { should == "～ #{@upper_limit} #{@unit_name}" }
    end
    context '下限値のみが設定されている場合' do
      subject {Factory.create(:check_specified_limit,
          :upper_limit => nil,
          :lower_limit => @lower_limit,
          :unit_name => @unit_name)}
      its(:limit_description) { should == "#{@lower_limit} #{@unit_name} ～" }
    end
    context '上限値も下限値も設定されていない場合' do
      subject {Factory.create(:check_specified_limit,
          :upper_limit => nil,
          :lower_limit => nil,
          :unit_name => nil)}
      its(:limit_description) { should == "" }
    end

  end

  describe "resultsテーブルへの保存テスト" do
    before do
      @result_data = {:judgment => false, :abnormal_content => "異常内容", :corrective_action => 2}
    end

    share_examples_for "result_should_be_saved" do
      it "結果データが保存されること" do
        @check.save_result_with_validation(@result_data).should be_true
        @check.result.judgment.should == @result_data[:judgment]
        @check.result.abnormal_content.should == @result_data[:abnormal_content]
        @check.result.corrective_action.should == @result_data[:corrective_action]
      end
    end

    context "'results'テーブルにレコードが存在する場合" do
      before do
        @check = Factory.create(:check_has_result_for_save)
      end
      it_should_behave_like "result_should_be_saved"
    end

    context "'results'テーブルにレコードが存在しない場合" do
      before do
        @check = Factory.create(:check_does_not_have_result_for_save)
      end
      it_should_behave_like "result_should_be_saved"
    end
  end

  describe "cyclesテーブルとの関連付けのテスト" do
    context "'cycles'テーブルに関連付けられるレコードが存在する場合" do
      subject { Factory.create(:check_has_cycle) }
      its(:cycle) { should be_instance_of Cycle }
    end
    context "'cycles'テーブルに関連付けられるレコードが存在しない場合" do
      subject { Factory.create(:check_does_not_have_cycle) }
      its(:cycle) { should be_nil }
    end
  end

  describe "次回点検日時に'時間'を追加するテスト" do
    before do
      @hour_intaval = 4
      @check_by_shift = Factory.create(:check_scheduled_by_hour,
        :scheduled_datetime => "2010-10-18 12:00:00")
      @next_datetime = @check_by_shift.scheduled_datetime.to_datetime + Rational(@hour_intaval, 24)
    end
    it "指定された'時'を加算した値に更新されていること" do
      @check_by_shift.send(:add_scheduled_datetime_by_hour, @hour_intaval).should be_true
      @check_by_shift.scheduled_datetime.should == @next_datetime
    end
  end

  describe "次回点検日時に'月'を追加するテスト" do
    before do
      @month_intaval = 1
      @check_by_monthly = Factory.create(:check_scheduled_by_month,
        :scheduled_datetime => "2010-10-18 12:00:00")
      @next_datetime = @check_by_monthly.scheduled_datetime.to_datetime >> @month_intaval
    end
    it "指定された'月'を加算した値に更新されていること" do
      @check_by_monthly.send(:add_scheduled_datetime_by_month, @month_intaval).should be_true
      @check_by_monthly.scheduled_datetime.should == @next_datetime
    end
  end

  describe "次回点検日時を周期に応じて更新するテスト" do
    def create_cycle_and_check(unit_type)
      cycle = Factory.create(:cycle_only_title,
        :unit_type => unit_type,
        :interval => 1)
      @check = Factory.create(:check_scheduled_by_cycle,
        :cycle_id => cycle.id,
        :scheduled_datetime => "2010-10-18 12:00:00")
    end

    context "点検の周期が'時間'による周期の場合" do
      before do
        create_cycle_and_check(Cycle::UNIT_TYPES["HOURS"])
      end
      it "次回点検日時が周期で指定された時間だけ更新されていること" do
        @check.update_scheduled_datetime.should be_true
        @check.scheduled_datetime.should == Time.local(2010,10,18,13,00,00)
      end
    end

    context "点検の周期が'月'による周期の場合" do
      before do
        create_cycle_and_check(Cycle::UNIT_TYPES["MONTHS"])
      end
      it "次回点検日時が周期で指定された月だけ更新されていること" do
        @check.update_scheduled_datetime.should be_true
        @check.scheduled_datetime.should == Time.local(2010,11,18,12,00,00)
      end
    end

    context "点検の周期が'適切でない'場合" do
      before do
        create_cycle_and_check(nil)
      end
      it "次回点検日時が更新されないこと" do
        @check.update_scheduled_datetime.should be_false
      end
    end
  end

  describe "点検のマスタデータの次回点検日時を更新するテスト" do
    context "点検のマスタデータが正常な場合" do
      before do
        @cycle = Factory.create(:cycle_of_master, :unit_type => Cycle::UNIT_TYPES["HOURS"], :interval => 4)
        @master = Factory.create(:check_of_master, :cycle_id => @cycle.id, :scheduled_datetime => "2010-10-13 12:00:00")
        @check = Factory.create(:check_of_operation, :parent_id => @master.id, :scheduled_datetime => "2010-10-13 12:00:00")
      end
      it "マスタの次回点検日時が更新ができること" do
        lambda{@check.update_master_schedule!}.should_not raise_error(ActiveRecord::RecordInvalid)
        @master.reload
        @master.scheduled_datetime.should == Time.local(2010,10,13,16,00,00)
      end
    end
    context "点検のマスタデータが異常な場合" do
      before do
        @cycle = Factory.create(:cycle_of_master, :unit_type => nil)
        @master = Factory.create(:check_of_master, :cycle_id => @cycle.id, :scheduled_datetime => "2010-10-13 12:00:00")
        @check = Factory.create(:check_of_operation, :parent_id => @master.id, :scheduled_datetime => "2010-10-13 12:00:00")
      end
      it "更新メソッドで例外し、点検日時が更新されないこと" do
        lambda{@check.update_master_schedule!}.should raise_error(ActiveRecord::RecordInvalid)
        @master.reload
        @master.scheduled_datetime.should == Time.local(2010,10,13,12,00,00)
      end
    end
  end

  describe "inspectionsテーブルとの関連付けのテスト" do
    context "'inspections'テーブルに関連付けられるレコードが存在する場合" do
      subject { Factory.create(:check_has_inspection) }
      its(:inspection) { should be_instance_of Inspection }
    end
    context "'inspections'テーブルに関連付けられるレコードが存在しない場合" do
      subject { Factory.create(:check_does_not_have_inspection) }
      its(:inspection) { should be_nil }
    end
  end

  describe "直近の点検結果を取得するテスト" do
    context "既存点検の場合" do
      before do
        @master = Factory.create(:check_of_master_for_getting_latest_result)
        @scheduled_datetimes = ["2010-10-01 00:00:00", "2010-10-08 00:00:00", "2010-10-15 00:00:00", "2010-10-15 06:00:00"]
        inspections, @checks, @results = [], [], []
        @scheduled_datetimes.each_with_index do |scheduled_datetime, i|
          inspections[i] = Factory.create(:inspection_for_getting_latest_result,
            :staff_code => "staff#{i}")
          @checks[i] = Factory.create(:check_of_operation_for_getting_latest_result,
            :inspection_id => inspections[i].id,
            :parent_id => @master.id,
            :scheduled_datetime => scheduled_datetime)
          @results[i] = Factory.create(:result_for_getting_latest_result,
            :check_id => @checks[i].id,
            :judgment => true)
        end
      end
      it "直近の点検結果を取得できること" do
        @master.latest_check.should == @checks[@scheduled_datetimes.size - 1]
        @checks[@scheduled_datetimes.size - 1].judgment.should == @results[@scheduled_datetimes.size - 1].judgment
        @master.latest_judgment.should == @results[@scheduled_datetimes.size - 1].judgment
      end
    end
    context "初回点検の場合" do
      before do
        @master = Factory.create(:check_of_master_for_getting_latest_result)
      end
      it "nilを取得できること" do
        @master.latest_check.should be_nil
        @master.latest_judgment.should be_nil
      end
    end
    context "点検未実施の場合" do
      before do
        @master = Factory.create(:check_of_master_for_getting_latest_result)
        inspection = Factory.create(:inspection_for_getting_latest_result)
        @check = Factory.create(:check_of_operation_for_getting_latest_result,
          :inspection_id => inspection.id,
          :parent_id => @master.id,
          :scheduled_datetime => "2010-10-15 00:00:00")
      end
      it "nilを取得できること" do
        @master.latest_check.should be_nil
        @check.judgment.should be_nil
        @master.latest_judgment.should be_nil
      end
    end
    context "直近の点検が未完了の場合" do
      before do
        @master = Factory.create(:check_of_master_for_getting_latest_result)
        inspection_1st = Factory.create(:inspection_for_getting_latest_result,
          :staff_code => "staff01")
        inspection_2nd = Factory.create(:inspection_for_getting_latest_result)
        @check_1st = Factory.create(:check_of_operation_for_getting_latest_result,
          :inspection_id => inspection_1st.id,
          :parent_id => @master.id,
          :scheduled_datetime => "2010-10-08 00:00:00")
        @check_2nd = Factory.create(:check_of_operation_for_getting_latest_result,
          :inspection_id => inspection_2nd.id,
          :parent_id => @master.id,
          :scheduled_datetime => "2010-10-15 00:00:00")
        @result_1st = Factory.create(:result_for_getting_latest_result,
          :check_id => @check_1st.id,
          :judgment => true)
        @result_2nd = Factory.create(:result_for_getting_latest_result,
          :check_id => @check_2nd.id,
          :judgment => false,
          :abnormal_content => "異常内容を入力しました。")
      end
      it "完了した直近の点検結果を取得できること" do
        @master.latest_check.should == @check_1st
        @check_1st.judgment.should == @result_1st.judgment
        @master.latest_judgment.should == @result_1st.judgment
      end
    end
  end

  describe "点検項目をマスタから作成するテスト" do
    before do
      @cycle = Factory.create(:cycle_for_making_check_child)
      @part = Factory.create(:part_for_making_check_child,
        :sequence => 3)
      @inspection = Factory.create(:inspection_for_making_check_child)
      @master = Factory.create(:check_for_making_check_child,
        :part_id => @part.id,
        :cycle_id => @cycle.id,
        :sequence => 0,
        :scheduled_datetime => "2010-11-01 09:00:00")
      @sequence = 5
    end
    it "点検項目が作成できること" do
      @master.make_child(@sequence).should be_instance_of Check
    end
    it "作成した点検項目の各データが正しいこと" do
      @check = @master.make_child(@sequence)
      @check.inspection_id.should be_nil
      @check.part_id.should == @master.part_id
      @check.item.should == @master.item
      @check.operation.should == @master.operation
      @check.criterion.should == @master.criterion
      @check.entry_type.should == @master.entry_type
      @check.unit_name.should == @master.unit_name
      @check.sequence.should == @sequence
      @check.upper_limit.should == @master.upper_limit
      @check.lower_limit.should == @master.lower_limit
      @check.parent_id.should == @master.id
      @check.cycle_id.should be_nil
      @check.cycle_title.should == @cycle.title
      @check.scheduled_datetime.should == @master.scheduled_datetime
      @check.part_name.should == @part.name
    end
  end

  describe "マスタデータから指定期間内の点検結果一覧を取得するテスト" do
    # 以下のデータを作成して6日前～当日の配列を取得することをテストする。
    #                   |<-------------------- 取得する範囲 -------------------------->|
    #          |7日前   |6日前   |5日前   |4日前   |3日前   |2日前   |1日前   |当日    |1日後   |
    # checks[0]|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|○|
    # checks[1]|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
    # checks[2]|  |  |  |  |○|  |  |  |○|  |○|  |○|  |  |○|  |  |  |○|  |  |  |○|  |  |  |
    def create_child_and_result(inspection_id, index)
      check = @masters[index].make_child(@masters[index].sequence)
      check.inspection_id = inspection_id
      check.save!
      @checks[index] << check
      Factory.create(:result_for_rusult_list_within_the_period,
        :check_id => check.id)
    end
    before(:all) do
      inspection_period = InspectionPeriod.new(DateTime.now)
      start_datetime = inspection_period.start_datetime
      next_start_datetime = inspection_period.next_period.start_datetime
      @masters, @checks, @lists = [], [[],[],[]], []
      @checks.size.times do |i|
        @masters << Factory.create(:check_for_result_list_within_the_period,
          :sequence => i)
      end
      @inspections = 27.times.collect do |i|
        Factory.create(:inspection_for_result_list_within_the_period,
          :updated_at => start_datetime - 1 + Rational(8 * i, 24))
      end
      @inspections.each_with_index do |inspection, i|
        create_child_and_result(inspection.id, 0)
        if [4, 8, 10, 12, 15, 19, 23].include?(i)
          create_child_and_result(inspection.id, 2)
        end
      end
      @checks.size.times do |i|
        @lists[i] = @masters[i].result_list_within_the_period(start_datetime, next_start_datetime)
      end
    end
    after(:all) do
      Cycle.destroy_all
      Part.destroy_all
      Inspection.destroy_all
      Check.destroy_all
      Result.destroy_all
    end
    context "1日3点検が存在する場合(境界値テスト)" do
      it "点検日時とその点検が配列要素と一致すること" do
        @lists[0].each_with_index do |day, i|
          day.each_with_index do |shift, j|
            shift.should be_instance_of Check
            shift.should == @checks[0][(i + 1) * 3 + j]
          end
        end
      end
    end
    context "期間中点検が存在しない場合(点検無の配列要素の整合性テスト)" do
      it "点検日時とその点検が配列要素と一致すること" do
        @lists[1].each_with_index do |day, i|
          day.each_with_index do |shift, j|
            shift.should be_nil
          end
        end
      end
    end
    context "1日1点検が存在する場合(点検有無の配列要素の整合性テスト)" do
      it "点検日時とその点検が配列要素と一致すること" do
        check_index = {1 => 0, 5 => 1, 7 => 2, 9 => 3, 12 => 4, 16 => 5, 20 => 6}
        @lists[2].each_with_index do |day, i|
          day.each_with_index do |shift, j|
            if check_index.include?(i * 3 + j)
              shift.should be_instance_of Check
              shift.should == @checks[2][check_index[i * 3 + j]]
            else
              shift.should be_nil
            end
          end
        end
      end
    end
  end

  describe "点検項目データと紐付く点検データと点検結果データと部位データを取得するテスト" do
    def create_check_with_inspection_and_result_and_part(params = {:with_result => false})
      @check = Factory.create(:check_master_for_find_with_inspection_and_result_and_part).make_child(0)
      return unless params[:with_result]
      @check.save_result_with_validation({:judgment => false}, false)
      @check.inspection = Factory.create(:inspection_for_find_with_inspection_and_result_and_part, :staff_code => "1234567")
      @check.save!
    end
    context "完了点検データの場合" do
      before do
        create_check_with_inspection_and_result_and_part(:with_result => true)
        @check_include_result_and_inspection_and_part = Check.find_with_inspection_and_result_and_part(@check.id)
      end
      it "点検項目データが取得できること" do
        @check_include_result_and_inspection_and_part.should be_instance_of Check
        @check_include_result_and_inspection_and_part.should == @check
      end
      it "点検項目データに関連するデータが取得できること" do
        @check_include_result_and_inspection_and_part.inspection.should be_instance_of Inspection
        @check_include_result_and_inspection_and_part.inspection.should == @check.inspection
        @check_include_result_and_inspection_and_part.result.should be_instance_of Result
        @check_include_result_and_inspection_and_part.result.should == @check.result
        @check_include_result_and_inspection_and_part.part.should be_instance_of Part
        @check_include_result_and_inspection_and_part.part.should == @check.part
      end
    end
    context "未完了点検データの場合" do
      before do
        create_check_with_inspection_and_result_and_part(:with_result => false)
      end
      it "点検項目データが取得できないこと" do
        lambda{Check.find_with_inspection_and_result_and_part(@check.id)}.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    context "点検マスタデータの場合" do
      before do
        @check_master = Factory.create(:check_master_for_find_with_inspection_and_result_and_part)
      end
      it "点検項目データが取得できないこと" do
        lambda{Check.find_with_inspection_and_result_and_part(@check_master.id)}.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
