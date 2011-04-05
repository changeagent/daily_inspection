require 'spec_helper'

describe Equipment do
  describe "partsテーブルとの関連付けテスト" do
    # 設備と関連付けられた部位を生成する。
    # === 引き数
    # parts_count 部位数
    # === 戻り値
    # なし
    def create_equipment_and_related_part(parts_count)
      @equipment = Factory.create(:equipment_has_parts)
      parts_count.times.collect {|i| Factory.create(:part_belongs_to_equipment, :sequence => i, :equipment_id => @equipment.id)}
    end
    context "partsテーブルに関連するレコードが存在する場合" do
      before do
        @parts_count = 2
        create_equipment_and_related_part(@parts_count)
      end
      it "Partオブジェクトを要素に持つ配列が取得できること" do
        @equipment.should have(@parts_count).parts
        @parts_count.times.each {|i| @equipment.parts[i].should be_instance_of(Part)}
      end
    end

    context "partsテーブルに関連するレコードが存在しない場合" do
      before do
        create_equipment_and_related_part(0)
      end
      it "要素が空の配列を取得すること" do
        @equipment.should have(0).parts
      end
    end
  end

  describe "任意の日時における'設備'毎の点検データを抽出するテスト" do
    # 設備と部位を作成し、指定日時に点検をスケジューリングします。
    # === 引き数
    # datetime 日時
    # === 戻り値
    # なし
    def create_check_at_each_equipment_and_scheduled_at(datetime)
      @parts_count, @checks_count = 2, 2
      @equipment = Factory.create(:equipment_has_checks_throw_part)
      @parts = @parts_count.times.collect {|i| Factory.create(:part_at_each_equipment, :sequence => i, :equipment_id => @equipment.id)}
      @parts.each do |part|
        @checks_count.times.collect do |i|
          Factory.create(:check_at_each_equipment_scheduled_at, :part_id => part.id, :scheduled_datetime => datetime, :sequence => i)
        end
      end
    end

    context "実施対象となる点検データが存在する場合" do
      before do
        @now = DateTime.now
        create_check_at_each_equipment_and_scheduled_at(@now - Rational(1, 24))
      end
      it "点検データがCheckオブジェクトを要素とする配列として取得できること" do
        Equipment.scheduled_checks(@equipment.id, DateTime.now).should have(@parts_count * @checks_count).checks
      end
    end

    context "実施対象となる点検データが存在しない場合" do
      before do
        @now = DateTime.now
        create_check_at_each_equipment_and_scheduled_at(@now + Rational(1, 24))
      end
      it "要素が空の配列を取得すること" do
        Equipment.scheduled_checks(@equipment.id, DateTime.now).should have(0).items
      end
    end
  end

  describe "点検開始時のテスト" do
    before(:all) do
      cycle = Factory.create(:cycle_of_shift_for_start_inspection)
      @equipment_id = Factory.create(:equipment_for_start_inspection).id
      @part_count, @check_count = 2, 2
      @check_masters = []
      @now = DateTime.now
      @part_count.times.each do |part_seq|
        part = Factory.create(:part_for_start_inspection,
          :name => "部位_#{part_seq}",
          :sequence => part_seq,
          :equipment_id => @equipment_id)
        @check_count.times.each do |check_seq|
          @check_masters << Factory.create(:check_of_master_for_start_inspection,
            :part_id => part.id,
            :cycle_id => cycle.id,
            :sequence => check_seq,
            :scheduled_datetime => @now)
        end
      end
    end
    after(:all) do
      Check.destroy_all
      Part.destroy_all
      Equipment.destroy_all
      Cycle.destroy_all
    end
    context "点検開始できる場合" do
      it "点検マスタデータから点検項目データを作成できること" do
        first_check_id = Equipment.start_inspection(@equipment_id, @now + Rational(1, 24))
        check = Check.find(:first, :conditions => ['parent_id = ?', @check_masters[0].id])
        first_check_id.should == check.id
        checks = Check.find(:all,
          :conditions => ['inspection_id = ?', check.inspection_id],
          :order => 'sequence ASC')
        checks.should have(@part_count * @check_count).checks
        (@part_count * @check_count).times.each do |i|
          checks[i].parent_id.should == @check_masters[i].id
        end
      end
    end
    context "点検開始できない場合" do
      it "点検マスタデータから点検項目データを作成できないこと" do
        Equipment.start_inspection(@equipment_id, @now - Rational(1, 24)).should be_nil
      end
    end
  end

  # 設備、部位、点検内容(点検サイクル含む)を生成する。
  # === 引き数
  # なし
  # === 戻り値
  # なし
  def create_equipment_and_part_and_check_of_parent_included_cycle(parts_count, check_masters_count)
    @datetime = DateTime.now
    @equipment = Factory.create(:equipment_for_check_of_parents_included_part_and_cycle) 
    parts = parts_count.times.collect do |i|
      Factory.create(:part_for_check_of_parents_included_part_and_cycle, :equipment_id => @equipment.id, :sequence => i)
    end
    @check_masters = parts.collect do |part|
      check_masters_count.times.collect do |i|
        Factory.create(:check_for_check_of_parents_included_part_and_cycle, :part_id => part.id, :parent_id => nil, :sequence => i)
      end
    end.flatten!
  end

  describe "設備に紐付く点検内容（点検マスタ）を取得するテスト" do
    context "設備に紐付く点検内容がある場合" do
      before do
        @parts_count, @check_masters_count = 2, 2
        create_equipment_and_part_and_check_of_parent_included_cycle(@parts_count, @check_masters_count)
      end
      it "Checkクラスの配列を取得すること" do
        @equipment.check_masters.should have(@parts_count * @check_masters_count).checks
        @equipment.check_masters.each_with_index {|check_master, i| check_master.sequence.should ==  @check_masters[i].sequence}
      end
    end
    context "設備に紐づく点検内容が無い場合" do
      before do
        create_equipment_and_part_and_check_of_parent_included_cycle(2, 0)
      end
      it "空の配列を取得すること" do
        @equipment.check_masters.should have(0).items
      end
    end
  end

  describe "直近7日分の点検結果データを作成するテスト" do
    context "設備に紐付く点検内容がある場合" do
      before do
        @parts_count, @check_masters_count = 2, 2
        create_equipment_and_part_and_check_of_parent_included_cycle(@parts_count, @check_masters_count)
        # inspectionとresultを追加で生成する
        @check_masters.each do |master|
          5.times.each do |i|
            inspection = Factory.create(:inspection_for_check_of_parents_included_part_and_cycle, 
                                        :updated_at => @datetime - Rational(i + 1, 24))
            check = Factory.create(:check_for_check_of_parents_included_part_and_cycle, 
                                   :inspection_id => inspection.id,
                                   :part_id => master.part.id, 
                                   :parent_id => master.id, 
                                   :sequence => master.sequence)
            result = Factory.create(:result_for_check_of_parents_included_part_and_cycle, 
                                    :check_id => check.id)
          end
        end
      end
      it "Checkクラスの配列を取得すること" do
        Equipment.list_of_result(@equipment.id, @datetime).should have(@parts_count * @check_masters_count).items
        Equipment.list_of_result(@equipment.id, @datetime).each_with_index do |array, i|
          array.should have(8).items
          array[0].should be_instance_of Check
          array[0].sequence.should == @check_masters[i].sequence
          7.times.each do |i|
            array[i + 1].should have(3).items
            array[i + 1].each do |elem|
              elem.should be_instance_of Check unless elem.nil?
            end
          end
        end
      end
    end
    context "設備に紐づく点検内容が無い場合" do
      before do
        create_equipment_and_part_and_check_of_parent_included_cycle(2, 0)
      end
      it "空の配列を取得すること" do
        Equipment.list_of_result(@equipment.id, DateTime.now).should have(0).items
      end
    end
  end
end
