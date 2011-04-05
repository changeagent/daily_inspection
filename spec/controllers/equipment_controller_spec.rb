require 'spec_helper'

describe EquipmentController do

  # 関連する工程、設備、部位を生成します。
  # === 引き数
  # parts_count 生成する部位データの数
  # checks_count_by_part 部位データ毎に生成する点検データの数
  # === 戻り値
  # なし
  def create_station_and_equipment_and_parts_and_checks(parts_count, checks_count_by_part)
    station = Factory.create(:station_saved_in_session)
    @equipment = Factory.create(:equipment_requested_from_web_api, :station_id => station.id)
    @parts = parts_count.times.collect do |i|
      Factory.create(:part_in_equipment_requested_from_web_api, :equipment_id => @equipment.id, :name => "part_#{i}", :sequence => i)
    end
    @checks = @parts.collect do |part|
      checks_count_by_part.times.collect do |i|
        Factory.create(:check_scheduled_at_1_hour_before, :part_id => part.id, :sequence => i)
      end
    end
    @checks.flatten!
  end

  describe "'show_scheduled_checks/:id'アクションのテスト" do
    context "点検が存在する場合" do
      before do
        @parts_count, @checks_count_by_part = 2, 2
        create_station_and_equipment_and_parts_and_checks(@parts_count, @checks_count_by_part)
        get 'show_scheduled_checks', :id => @equipment.id
      end
      it "点検一覧が取得できること" do
        assigns[:scheduled_checks].should be_instance_of Array
        assigns[:scheduled_checks].should have(@parts_count * @checks_count_by_part).checks
      end
      it { response.should be_success }
      it { response.should render_template("equipment/show_scheduled_checks") }
    end
    context "点検データが存在しない場合" do
      before do
        create_station_and_equipment_and_parts_and_checks(2, 0)
        get 'show_scheduled_checks', :id => @equipment.id
      end
      it { response.should be_redirect }
      it "stations/operator_indexアクションへリダイレクトされること" do
        response.should redirect_to(:controller => 'stations', :action => 'operator_index')
      end
    end
  end

  describe "'show_list_of_result/:id'アクションのテスト" do
    context "点検が存在する場合" do
      before do
        @parts_count, @checks_count_by_part = 2, 2
        create_station_and_equipment_and_parts_and_checks(@parts_count, @checks_count_by_part)
        get 'show_list_of_result', :id => @equipment.id
      end
      it "本日の日付データと、一覧データ（配列）が取得できること" do
        assigns[:today].should be_instance_of DateTime
        assigns[:checks].should be_instance_of Array
        assigns[:checks].should have(@parts_count * @checks_count_by_part).items
      end
      it "equipment/show_list_of_resultテンプレートが、レイアウト'pc'を用いてレンダリングされること" do
        response.should be_success
        response.layout.should == "layouts/pc"
        response.should render_template("equipment/show_list_of_result")
      end
    end
    context "点検が存在しない場合" do
      before do
        create_station_and_equipment_and_parts_and_checks(2, 0)
        get 'show_list_of_result', :id => @equipment.id
      end
      it "stations/ladder_indexアクションへリダイレクトされること" do
        response.should be_redirect
        response.should redirect_to(:controller => 'stations', :action => 'ladder_index')
      end
    end
  end

  describe "'start_inspection/:id'アクションのテスト" do
    before(:all) do
      cycle = Factory.create(:cycle_of_shift_for_start_inspection_in_controllers)
      @equipment_id = Factory.create(:equipment_for_start_inspection_in_controllers).id
      @part_count, @check_count = 2, 2
      @check_masters = []
      @now = DateTime.now
      @part_count.times.each do |part_seq|
        part = Factory.create(:part_for_start_inspection_in_controllers,
                              :name => "部位_#{part_seq}",
                              :sequence => part_seq,
                              :equipment_id => @equipment_id)
        @check_count.times.each do |check_seq|
          @check_masters << Factory.create(:check_of_master_for_start_inspection_in_controllers,
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
    context "点検が開始できる場合" do
      before do
        session[:start_datetime] = @now + Rational(1, 24)
        post 'start_inspection', :id => @equipment_id
      end
      it "点検画面にリダイレクトされること" do
        check_id = Check.find(:first, :conditions => ['parent_id = ?', @check_masters[0].id]).id
        response.should be_redirect
        response.should redirect_to(:controller => 'checks', :action => 'show', :id => check_id)
      end
    end
  end

end