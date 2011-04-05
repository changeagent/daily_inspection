require 'spec_helper'

describe Part do
  describe "checksテーブルとの関連付けテスト" do
    # 部位と関連付けられた点検データを生成する。
    # === 引き数
    # check_count 点検数
    # === 戻り値
    # なし
    def create_parts_and_related_checks(check_count)
      @part = Factory.create(:part_has_checks)
      @checks = check_count.times.collect {|i| Factory.create(:check_belongs_to_part, :sequence => i, :part_id => @part.id)}
    end

    context "checksテーブルに関連するレコードが存在する場合" do
      before do
        @check_count = 2
        create_parts_and_related_checks(@check_count)
      end
      it "Partオブジェクトを要素に持つ配列が取得できること" do
        @part.should have(@check_count).checks
        @check_count.times.each {|i| @part.checks[i].should be_instance_of(Check)}
      end
    end

    context "checksテーブルに関連するレコードが存在しない場合" do
      before do
        create_parts_and_related_checks(0)
      end
      it "要素が空の配列を取得すること" do
        @part.should have(0).checks
      end
    end
  end

  describe "任意の日時における'部位'の点検データを抽出するテスト" do
    # 部位を作成し、指定日時に点検をスケジューリングします。
    # === 引き数
    # datetime 日時
    # === 戻り値
    # なし
    def create_part_and_scheduled_checks_at(datetime)
      @checks_count = 2
      @part = Factory.create(:part_has_checks_spacified_scheduled_datetime)
      @checks = @checks_count.times.collect do |i|
          Factory.create(:check_at_each_part_scheduled_at,
                         :part_id => @part.id, 
                         :sequence => i,
                         :scheduled_datetime => datetime)
      end
    end

    context "実施対象となる点検データが存在する場合" do
      before do
       @now = DateTime.now
       create_part_and_scheduled_checks_at(@now - Rational(1, 24))
      end
      it "点検データがCheckオブジェクトを要素とする配列として取得できること" do
        @part.scheduled_checks_at(@now).should have(@checks_count).items
        @part.scheduled_checks_at(@now).each {|element| element.should be_instance_of(Check)}
      end
      it "点検データがsequenceの順に並んでいること" do
        @checks.each_with_index {|check, i| @part.checks[i].sequence.should == check.sequence}
      end
    end
    context "実施対象となる点検データが存在しない場合" do
      before do
        @now = DateTime.now
        create_part_and_scheduled_checks_at(@now + Rational(1, 24))
      end
      it "要素が空の配列を取得すること" do
        @part.scheduled_checks_at(@now).should have(0).items
      end
    end
  end

end
