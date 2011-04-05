Given /^以下の工程と設備を登録している:$/ do |table|
  table.rows.each do |station_name, equipment_name|
    station = Station.find_by_name(station_name) || Station.create!(:name => station_name)
    station.equipment << Equipment.create!(:name => equipment_name) unless (equipment_name.nil? || equipment_name == "")
  end
end

Then /^画面の右上に以下の工程名が表示されていること$/ do |expected|
  expected.diff!(tableish('table tr.selected_station_name', 'td'))
end