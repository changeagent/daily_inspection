require 'spec_helper'

describe "/stations/_station_list" do
  describe "部分テンプレート'station_list'に工程を表示するテスト" do
    before do
      @stations = assigns[:stations] = 3.times.collect do |i|
        Factory.create(:station_for_station_body, :name => "工程#{i}")
      end
    end

    share_examples_for "station_list_should_be_shown" do
      it { response.should be_success }
      it "'div id=station_list'に工程名が表示されていること" do
        response.should have_tag('div#station_list') do
          @stations.each_with_index do |station, i|
            with_tag("tr:nth-of-type(#{i + 1})") do
              with_tag('td', station.name) do
                with_tag("a", :attributes => {:href => "/stations/#{@action_name}/#{station.id}"})
              end
            end
          end
          without_tag("tr:nth-of-type(#{@stations.size + 1})")
        end
      end
    end

    context "日常点検メニューで表示する場合" do
      before do
        @action_name = 'operator_index'
        render :partial => 'stations/station_list', :locals => {:action_name => @action_name}
      end
      it_should_behave_like "station_list_should_be_shown"
    end

    context "日常点検確認メニューで表示する場合" do
      before do
        @action_name = 'ladder_index'
        render :partial => 'stations/station_list', :locals => {:action_name => @action_name}
      end
      it_should_behave_like "station_list_should_be_shown"
    end

  end
end
