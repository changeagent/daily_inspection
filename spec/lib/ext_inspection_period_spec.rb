require 'spec_helper'

describe "ExtInspectionPeriod" do
  describe "InspectionPeriod" do
    describe "インスタンスを生成するテスト" do
      context "対象期間に当日を含む場合" do
        it "インスタンスが生成されること" do
          inspection_period = InspectionPeriod.new(DateTime.new(2010, 11, 19, 9, 0, 0, Rational(9, 24)))
          inspection_period.should be_instance_of InspectionPeriod
          inspection_period.start_datetime.should == DateTime.new(2010, 11, 13, 9, 0, 0, Rational(9, 24))
        end
      end
      context "対象期間に当日を含まない場合" do
        it "インスタンスが生成されること" do
          inspection_period = InspectionPeriod.new(DateTime.new(2010, 11, 19, 8, 59, 59, Rational(9, 24)))
          inspection_period.should be_instance_of InspectionPeriod
          inspection_period.start_datetime.should == DateTime.new(2010, 11, 12, 9, 0, 0, Rational(9, 24))
        end
      end
    end

    describe "次期間のインスタンスを生成するテスト" do
      context "対象期間に当日を含む場合" do
        it "次期間のインスタンスが生成されること" do
          next_inspection_period = InspectionPeriod.new(DateTime.new(2010, 11, 19, 9, 0, 0, Rational(9, 24))).next_period
          next_inspection_period.should be_instance_of InspectionPeriod
          next_inspection_period.start_datetime.should == DateTime.new(2010, 11, 20, 9, 0, 0, Rational(9, 24))
        end
      end
      context "対象期間に当日を含まない場合" do
        it "次期間のインスタンスが生成されること" do
          next_inspection_period = InspectionPeriod.new(DateTime.new(2010, 11, 19, 8, 59, 59, Rational(9, 24))).next_period
          next_inspection_period.should be_instance_of InspectionPeriod
          next_inspection_period.start_datetime.should == DateTime.new(2010, 11, 19, 9, 0, 0, Rational(9, 24))
        end
      end
    end
  end
end
