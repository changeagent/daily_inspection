require 'spec_helper'

describe StationsController do
  share_examples_for "should render to template 'stations/operator_index'" do
    it {
      response.should be_success
      response.should render_template("stations/operator_index")
    }
  end

  share_examples_for "should render to template 'stations/ladder_index' with layout 'pc'" do
    it "レイアウトファイル'pc'を使用して'stations/ladder_index'にレンダリングされること" do
      response.should be_success
      response.layout.should == "layouts/pc"
      response.should render_template("stations/ladder_index")
    end
  end

  share_examples_for "should get all data of station table" do
    it "stationデータを全て取得できること" do
      assigns[:stations].should have(@stations_count).items
      @stations_count.times do |idx|
        assigns[:stations][idx].should be_instance_of Station
        assigns[:stations][idx].should == @stations[idx]
      end
    end
  end
  
  share_examples_for "should get stations and equipment" do
    it { response.should be_success }
    it_should_behave_like "should get all data of station table"

    it "選択したstationのデータを取得できること" do
      assigns[:station].should be_instance_of Station
      assigns[:station].should == @station
    end

    it "取得したstationデータのidをsession[:station_id]にセットしていること" do
      session[:station_id].should == assigns[:station].id
    end

    it "取得したstationデータに属するequipmentデータを全て取得できること" do
      assigns[:station].equipment.should have(@equipment_count).items
      assigns[:station].equipment.each do |equipment|
        equipment.should be_instance_of Equipment
      end
    end
  end

  describe "operator_indexとladder_indexアクションのテスト" do
    before(:all) do
      @stations_count, @equipment_count = 5, 2
      @stations = @stations_count.times.collect {Factory.create(:station_data_for_index)}
      @station = @stations.last
      @equipment_count.times.each {Factory.create(:equipment_data_for_index, :station_id => @station.id)}
    end

    after(:all) do
      @stations.each {|station|
        station.equipment.destroy_all
        station.destroy
      }
    end

    describe "日常点検メニュー画面の場合のテスト" do
      context "stationデータを表示する場合" do
        before do
          get 'operator_index'
        end

        it_should_behave_like "should get all data of station table"
        it_should_behave_like "should render to template 'stations/operator_index'"
      end

      context "選択したstationのデータに属するequipmentデータを表示する場合" do
        before do
          get 'operator_index', :id => @station.id
        end

        it_should_behave_like "should get stations and equipment"
        it_should_behave_like "should render to template 'stations/operator_index'"
      end

      context "sessionにあるstation_idからstationのデータに属するequipmentデータを表示する場合" do
        before do
          session[:station_id] = @station.id
          get 'operator_index'
        end

        it_should_behave_like "should get stations and equipment"
        it_should_behave_like "should render to template 'stations/operator_index'"
      end
    end

    describe "日常点検確認メニュー画面の場合のテスト" do
      context "stationデータを表示する場合" do
        before do
          get 'ladder_index'
        end

        it_should_behave_like "should get all data of station table"
        it_should_behave_like "should render to template 'stations/ladder_index' with layout 'pc'"
      end

      context "選択したstationのデータに属するequipmentデータを表示する場合" do
        before do
          get 'ladder_index', :id => @station.id
        end

        it_should_behave_like "should get stations and equipment"
        it_should_behave_like "should render to template 'stations/ladder_index' with layout 'pc'"
      end

      context "sessionにあるstation_idからstationのデータに属するequipmentデータを表示する場合" do
        before do
          session[:station_id] = @station.id
          get 'ladder_index'
        end

        it_should_behave_like "should get stations and equipment"
        it_should_behave_like "should render to template 'stations/ladder_index' with layout 'pc'"
      end
    end
  end
end
