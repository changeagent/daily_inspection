And /^以下の点検内容・点検結果を登録している:$/ do |table|
  table.rows.each do |station_name, equipment_name, cycle_title, part_name, part_sequence, item, master_sequence, operation, criterion, upper_limit, lower_limit, unit_name, entry_type, judgment, measured_value, abnormal_content, scheduled_datetime, inspection_staff_code, inspection_updated_at, check_sequence, inspection_id, result_staff_code, corrective_action, corrective_content, corrected_datetime|
    station = Station.find_by_name(station_name) || Station.create!(:name => station_name)
    station.equipment << equipment = Equipment.find_by_name_and_station_id(equipment_name, station.id) || Equipment.create!(:name => equipment_name)

    next if part_name == ""
    equipment.parts << part = Part.find_by_name_and_equipment_id(part_name, equipment.id) || Part.create!(:name => part_name, :sequence => part_sequence)

    next if cycle_title == "" || entry_type == ""
    cycle = Cycle.find_by_title(cycle_title)
    upper_limit = upper_limit == "" ? nil : upper_limit.to_f
    lower_limit = lower_limit == "" ? nil : lower_limit.to_f
    unit_name = nil if unit_name == ""
    entry_type = case entry_type; when "選択"; Check::ENTRY_TYPES["NORMAL_OR_ABNORMAL"]; when "入力"; Check::ENTRY_TYPES["MEASURED_VALUE"]; else; raise "点検方式の指定が正しくありません"; end
    check_master = Check.find_by_cycle_id_and_part_id_and_item_and_sequence(cycle.id, part.id, item, master_sequence) ||
                   Check.create!(:inspection_id => nil,
                                 :part_id => part.id,
                                 :item => item,
                                 :operation => operation,
                                 :criterion => criterion,
                                 :entry_type => entry_type,
                                 :unit_name => unit_name,
                                 :sequence => master_sequence,
                                 :upper_limit => upper_limit,
                                 :lower_limit => lower_limit,
                                 :parent_id => nil,
                                 :cycle_id => cycle.id,
                                 :cycle_title => nil,
                                 :scheduled_datetime => DateTime.now,
                                 :part_name => nil)

    next if scheduled_datetime == "" || inspection_updated_at == "" || inspection_id == ""
    check_data = check_master.make_child(check_sequence)
    check_data.update_attributes!(:inspection_id => inspection_id)
    judgment = case judgment; when "○"; true; when "×"; false; else; nil; end
    measured_value = measured_value == "" ? nil : measured_value.to_f
    abnormal_content = nil if abnormal_content == ""
    corrective_action = case corrective_action; when "交換"; Result::CORRECTIVE_ACTION_VALUES["EXCHANGE"]; when "調整"; Result::CORRECTIVE_ACTION_VALUES["ADJUSTMENT"]; when "清掃"; Result::CORRECTIVE_ACTION_VALUES["CLEANING"]; else; nil; end
    corrective_content = nil if corrective_content == ""
    result_staff_code = nil if result_staff_code == ""
    corrected_datetime = nil if corrected_datetime == ""
    Result.create!(:judgment => judgment,
                   :check_id => check_data.id,
                   :measured_value => measured_value,
                   :abnormal_content => abnormal_content,
                   :corrective_action => corrective_action,
                   :checked_datetime => inspection_updated_at,
                   :corrective_content => corrective_content,
                   :staff_code => result_staff_code,
                   :corrected_datetime => corrected_datetime)
    Inspection.find_or_create_by_id_and_staff_code_and_updated_at(inspection_id, inspection_staff_code, inspection_updated_at)
  end
end

Then /^設備"(.*)"の"点検結果一覧"画面を表示すること$/ do |equipment_name|
  equipment_id = Equipment.find_by_name(equipment_name).id
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to("点検結果一覧") + "/" + equipment_id.to_s
  else
    assert_equal path_to("点検結果一覧") + "/" + equipment_id.to_s, current_path
  end
end

And /^点検結果一覧画面に以下のヘッダ情報が表示されていること:$/ do |expected|
  expected.diff!(tableish('table tr.header_row', 'th'))
end

And /^点検結果一覧画面に以下の点検結果一覧が表示されていること:$/ do |expected|
  expected.raw.should == tableish('table tr.scroll_data_row', 'td:nth-child(n+1)')
end

Then /^"点検項目がありません"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end

When /^"(.*)"行目の点検、"(.*)"日目の"(.*)"シフト目の点検結果リンクをクリックする$/ do |line, day, shift|
  within("table > tr:nth-child(#{line.to_i}) td:nth-child(#{day.to_i * 3 + shift.to_i})") do
      click_link("×")
  end
end

Then /^点検ID"(.*)"、点検順"(.*)"の"(.*)"画面を表示すること$/ do |inspection_id, sequence, page_name|
  check_id = Check.find_by_inspection_id_and_sequence(inspection_id, sequence).id
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name) + "/" + check_id.to_s
  else
    assert_equal path_to(page_name) + "/" + check_id.to_s, current_path
  end
end

And /^異常対応確認入力画面に以下のヘッダ情報が表示されていること:$/ do |expected|
  expected.diff!(tableish('table#header tr', 'th'))
end

And /^異常対応確認入力画面に以下の内容が表示されること:$/ do |table|
  table.rows.each do |title, value, input_type, name|
    Then %!I should see "#{title}"!
    case input_type
    when ""
      Then %!I should see "#{value}"!
    when "text"
      unless value == "(空欄)"
        response.should have_selector('input', :id => "correction_" + name, :type => input_type, :value => value)
      else
        response.should have_tag("input[id=?][type=?]", "correction_#{name}", input_type)
        response.should_not have_tag("input[id=?][type=?][value]", "correction_#{name}", input_type)
      end
    when "radio"
      value = case value
                when "交換"
                  Result::CORRECTIVE_ACTION_VALUES["EXCHANGE"]
                when "調整"
                  Result::CORRECTIVE_ACTION_VALUES["ADJUSTMENT"]
                when "清掃"
                  Result::CORRECTIVE_ACTION_VALUES["CLEANING"]
                when "(未選択)"
                  nil
                else
                  raise "対応・処置の指定が正しくありません"
              end
      unless value.nil?
        response.should have_selector('input', :checked => "checked", :id => "correction_" + name + "_" + value.to_s, :type => input_type, :value => value.to_s)
      else
        3.times do |i|
          response.should_not have_selector('input', :checked => "checked", :id => "correction_" + name + "_" + i.to_s, :type => input_type, :value => i.to_s)
        end
      end
    end
  end
end
