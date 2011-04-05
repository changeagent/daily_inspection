And /^以下の点検内容を登録している:$/ do |table|
  table.rows.each do |station_name, equipment_name, cycle_title, part_name, part_sequence, item, sequence, scheduled_datetime, last_judgment, index|
    station = Station.find_by_name(station_name) || Station.create!(:name => station_name)
    station.equipment << equipment = Equipment.find_by_name_and_station_id(equipment_name, station.id) || Equipment.create!(:name => equipment_name)
    equipment.parts << part = Part.find_by_name_and_equipment_id(part_name, equipment.id) || Part.create!(:name => part_name, :sequence => part_sequence)
    entry_type = Check::ENTRY_TYPES["NORMAL_OR_ABNORMAL"]
    part.checks << check_master = Check.create!(:item => item, :sequence => sequence, :cycle_id => Cycle.find_by_title(cycle_title).id, :entry_type => entry_type, :scheduled_datetime => DateTime.parse(scheduled_datetime.to_s))
    judgment = case last_judgment; when "○"; true; when "×"; false; else; nil; end
    check_data = check_master.make_child(index)
    check_data.save_result_with_validation({:judgment => judgment}, false)
    Inspection.create!(:staff_code => "0123456").checks << check_data # this is dummy inspection
  end
end

And /^"点検予定の内容がありません"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end
