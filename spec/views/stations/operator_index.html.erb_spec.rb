require 'spec_helper'

describe "/stations/operator_index" do
  describe "日常点検メニューを表示するテスト" do
    context "部分テンプレートを描画する場合" do
      before do
        @stations = assigns[:stations] = 3.times.collect do |i|
          Factory.create(:station_for_station_body, :name => "工程#{i}")
        end
        render 'stations/operator_index'
      end
      it { response.should be_success }
      it { response.should have_tag('div#station_list') }
      it { response.should have_tag('div#equipment_list') }
    end
  end
end