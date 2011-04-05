require 'spec_helper'

describe "/stations/_equipment_list" do
  describe "部分テンプレート'equipment_list'に工程名と設備を表示するテスト" do
    # 工程と設備を生成する。
    # === 引き数
    # station_count: 工程数、equipment_count 設備数
    # === 戻り値
    # なし
    def create_stations_and_equipment(station_count, equipment_count)
      @stations = assigns[:stations] = station_count.times.collect do |i|
        Factory.create(:station_for_equipment_body, :name => "工程#{i}")
      end
      @station = assigns[:station] = @stations[0]
      @stations.each do |station|
        equipment_count.times.each do |i|
          Factory.create(:equipment_for_equipment_body,:name => "設備#{i}",:station_id => station.id)
        end
      end
    end

    share_examples_for "equipment_list_should_be_shown" do
      it { response.should be_success }
      it "'div id=equipment_list'に設備名が表示されていること" do
        response.should have_tag('div#equipment_list') do
          have_tag('div#equipment_table_area') do
            with_tag("tr:nth-of-type(1)") do
              with_tag('td', @station.name)
            end
            @station.equipment.each_with_index do |equipment, i|
              with_tag("tr:nth-of-type(#{(i + 4) / 4 + 1})") if i % 4 == 0
              with_tag('td', equipment.name) do
                with_tag("a", :attributes => {:href => "/equipment/#{@action_name}/#{equipment.id}"})
              end
            end
          end
        end
      end
    end

    share_examples_for "equipment_list_should_not_be_shown" do
      it "'div id=equipment_list'に登録設備のない旨が表示されていること" do
        response.should have_tag('div#equipment_list') do
          with_tag("tr:nth-of-type(1)") do
            with_tag('td', @station.name)
          end
          with_tag("tr:nth-of-type(2)") do
            with_tag('td', t('errors.views.stations.index.no_registration_equipment'))
          end
          without_tag("tr:nth-of-type(3)")
        end
      end
    end
    
    describe "日常点検メニューで表示するとき" do
      before do
        @action_name = 'show_scheduled_checks'
      end

      context "工程に関連する設備の数が1～4の場合" do
        before do
          create_stations_and_equipment(1, 4)
          render :partial => 'stations/equipment_list', :locals => {:action => @action_name}
        end
        it_should_behave_like "equipment_list_should_be_shown"
      end

      context "工程に関連する設備の数が5～8の場合" do
        before do
          create_stations_and_equipment(1, 8)
          render :partial => 'stations/equipment_list', :locals => {:action => @action_name}
        end
        it_should_behave_like "equipment_list_should_be_shown"
      end

      context "工程に関連する設備がない場合" do
        before do
          create_stations_and_equipment(1, 0)
          render :partial => 'stations/equipment_list', :locals => {:action => @action_name}
        end
        it_should_behave_like "equipment_list_should_not_be_shown"
      end
    end

    describe "日常点検確認メニューで表示するとき" do
      before do
        @action_name = 'show_list_of_result'
      end

      context "工程に関連する設備の数が1～4の場合" do
        before do
          create_stations_and_equipment(1, 4)
          render :partial => 'stations/equipment_list', :locals => {:action => @action_name}
        end
        it_should_behave_like "equipment_list_should_be_shown"
      end

      context "工程に関連する設備の数が5～8の場合" do
        before do
          create_stations_and_equipment(1, 8)
          render :partial => 'stations/equipment_list', :locals => {:action => @action_name}
        end
        it_should_behave_like "equipment_list_should_be_shown"
      end

      context "工程に関連する設備がない場合" do
        before do
          create_stations_and_equipment(1, 0)
          render :partial => 'stations/equipment_list', :locals => {:action => @action_name}
        end
        it_should_behave_like "equipment_list_should_not_be_shown"
      end
    end

  end
end