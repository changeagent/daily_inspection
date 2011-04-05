Given /^以下の周期を登録している:$/ do |table|
  table.rows.each do |title, interval, unit_name|
    unit_type = case unit_name; when "時間"; Cycle::UNIT_TYPES["HOURS"]; when "ヶ月"; Cycle::UNIT_TYPES["MONTHS"]; else; raise "周期の単位指定が正しくありません"; end
    Cycle.create!(:title => title, :interval => interval, :unit_type => unit_type)
  end
end

Given /^以下の前回結果が登録された点検内容を登録している:$/ do |table|
  table.rows.each do |station_name, equipment_name, cycle_title, part_name, part_sequence, item, sequence, operation, criterion, scheduled_datetime, last_judgment, result_corrective_action, index|
    station = Station.find_by_name(station_name) || Station.create!(:name => station_name)
    station.equipment << equipment = Equipment.find_by_name_and_station_id(equipment_name, station.id) || Equipment.create!(:name => equipment_name)
    equipment.parts << part = Part.find_by_name_and_equipment_id(part_name, equipment.id) || Part.create!(:name => part_name, :sequence => part_sequence)
    entry_type = Check::ENTRY_TYPES["NORMAL_OR_ABNORMAL"]
    part.checks << check_master = Check.create!(:item => item, :sequence => sequence, :cycle_id => Cycle.find_by_title(cycle_title).id, :entry_type => entry_type, :operation => operation, :criterion => criterion, :scheduled_datetime => DateTime.parse(scheduled_datetime.to_s))
    judgment = case last_judgment; when "○"; true; when "×"; false; else; nil; end
    check_data = check_master.make_child(index)
    check_data.save_result_with_validation({:judgment => judgment}, false)
    Inspection.create!(:staff_code => "0123456").checks << check_data # this is dummy inspection
  end
end

Then /^設備"(.*)"の"点検開始"画面を表示すること$/ do |equipment_name|
  equipment_id = Equipment.find_by_name(equipment_name).id
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to("点検開始") + "/" + equipment_id.to_s
  else
    assert_equal path_to("点検開始") + "/" + equipment_id.to_s, current_path
  end
end

Then /^点検予定の一覧の先頭行に以下の名称が表示されること:$/ do |expected|
  expected.diff!(tableish('table tr.scheduled_header', 'th'))
end

Then /^点検順でソートされた以下の点検予定内容が表示されること:$/ do |expected|
  expected.diff!(tableish('table tr.scheduled_row', 'td'))
end

Then  /^"点検入力"画面を表示し、以下の点検内容を表示していること:$/ do |table|
  table.transpose.rows.each do |data_name, value|
    unless (value == "(空白)" || value == "(未選択)")
      return false unless response.body.should =~ /#{Regexp.escape(value)}/m
    end
  end
end

When /^点検結果で"正常"を選択する$/ do
  choose("result_judgment_true")
end

Then /^"点検者入力"画面に遷移すること$/ do
  URI.parse(current_url).path =~ /#{Regexp.escape(path_to("点検開始"))}/m
end

When /^点検者氏名コードに"(.*)"と入力する$/ do |value|
  fill_in("inspection_staff_code", :with => value)
end

Then /^以下の点検者氏名コードを表示していること:$/ do |table|
  table.rows.each do |title, value|
    Then %!I should see "#{title}"!
    unless value == "(空白)"
      response.should have_selector('input', :id => "inspection_staff_code", :type => "text", :value => value)
    else
      response.should have_tag("input[id=?][type=?]", "inspection_staff_code", "text")
      response.should_not have_tag("input[id=?][type=?][value]", "inspection_staff_code", "text")
    end
  end
end

Then /^工程名および設備名が表示されていないこと$/ do
  response.should have_selector('div', :id => "equipment_list")
  response.should_not have_selector('tr', :class => "selected_station_name")
  response.should_not have_selector('div', :id => "equipment_table_area")
end
