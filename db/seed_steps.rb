require 'cucumber'

def cuke_table_rows(table_str)
  Cucumber::Ast::Table.parse(table_str, nil, nil).rows
end

# 点検周期を登録する
#
def the_following_cycles_are_registered(table_str)
  cuke_table_rows(table_str).each do |title, interval, unit_name|
    unit_type = case unit_name; when "時間"; Cycle::UNIT_TYPES["HOURS"]; when "ヶ月"; Cycle::UNIT_TYPES["MONTHS"]; else; raise "周期の単位指定が正しくありません"; end
    Cycle.create!(:title => title, :interval => interval, :unit_type => unit_type)
  end
end

# 工程と設備を登録する
#
def the_following_stations_and_equipment_are_registerd(table_str)
  cuke_table_rows(table_str).each do |station_name, equipment_name|
    station = Station.find_by_name(station_name) || Station.create!(:name => station_name)
    station.equipment << Equipment.create!(:name => equipment_name) unless (equipment_name.nil? || equipment_name == "")
  end
end

# 点検マスタを登録する
#
def the_following_check_masters_are_registered(table_str)
  cuke_table_rows(table_str).each do |station_name, equipment_name, cycle_title, part_name, part_sequence, item, sequence, operation, criterion, lower_limit, upper_limit, unit_name, entry_type, scheduled_date_after, scheduled_time|
    station = Station.find_by_name(station_name) || Station.create!(:name => station_name)
    station.equipment << equipment = Equipment.find_by_name_and_station_id(equipment_name, station.id) || Equipment.create!(:name => equipment_name)

    next if part_name == ""
    equipment.parts << part = Part.find_by_name_and_equipment_id(part_name, equipment.id) || Part.create!(:name => part_name, :sequence => part_sequence)

    next if cycle_title == ""
    cycle = Cycle.find_by_title(cycle_title)
    lower_limit = lower_limit == "" ? nil : lower_limit.to_f
    upper_limit = upper_limit == "" ? nil : upper_limit.to_f
    unit_name = nil if unit_name == ""
    entry_type = case entry_type; when "選択式"; Check::ENTRY_TYPES["NORMAL_OR_ABNORMAL"]; when "入力式"; Check::ENTRY_TYPES["MEASURED_VALUE"]; else; raise "点検形式の指定が正しくありません"; end
    scheduled_date = Date.today + scheduled_date_after.to_i
    scheduled_datetime = "#{scheduled_date.year}/#{scheduled_date.month}/#{scheduled_date.day} #{scheduled_time}"
    Check.find_by_cycle_id_and_part_id_and_item_and_sequence(cycle.id, part.id, item, sequence) || Check.create!(:cycle_id => cycle.id, :part_id => part.id, :item => item, :sequence => sequence, :operation => operation, :criterion => criterion, :unit_name => unit_name, :lower_limit => lower_limit, :upper_limit => upper_limit, :entry_type => entry_type, :scheduled_datetime => scheduled_datetime)
  end
end

# 点検データを登録する
#
def the_following_checks_are_registered(table_str)
  cuke_table_rows(table_str).each do |station_name, equipment_name, cycle_title, part_name, part_sequence, item, master_sequence, inspection_date_before, checked_time, last_judgment, measured_value, abnormal_content, corrective_action_char, sequence, inspection_id, staff_code, inspection_time|
    station = Station.find_by_name(station_name) || Station.create!(:name => station_name)
    station.equipment << equipment = Equipment.find_by_name_and_station_id(equipment_name, station.id) || Equipment.create!(:name => equipment_name)
    
    next if part_name == ""
    equipment.parts << part = Part.find_by_name_and_equipment_id(part_name, equipment.id) || Part.create!(:name => part_name, :sequence => part_sequence)

    next if cycle_title == ""
    cycle = Cycle.find_by_title(cycle_title)
    check_master = Check.find_by_cycle_id_and_part_id_and_item_and_sequence(cycle.id, part.id, item, master_sequence) || Check.create!(:cycle_id => cycle.id, :part_id => part.id, :item => item, :sequence => master_sequence, :entry_type => Check::ENTRY_TYPES["NORMAL_OR_ABNORMAL"], :scheduled_datetime => DateTime.now)

    next if inspection_date_before == "" || inspection_time == "" || inspection_id == "" || staff_code == ""
    inspection_date = Date.today - inspection_date_before.to_i

    inspection_update_at = "#{inspection_date.year}/#{inspection_date.month}/#{inspection_date.day} #{inspection_time}"
    Inspection.find_or_create_by_id_and_staff_code_and_updated_at(inspection_id, staff_code, inspection_update_at)

    check_data = check_master.make_child(sequence)
    check_data.update_attributes!(:inspection_id => inspection_id)

    next if checked_time == ""
    judgment = case last_judgment; when "○"; true; when "×"; false; else; nil; end
    checked_date = "#{inspection_date.year}/#{inspection_date.month}/#{inspection_date.day} #{inspection_time}"
    checked_datetime = "#{inspection_date.year}/#{inspection_date.month}/#{inspection_date.day} #{checked_time}"

    corrective_action = case corrective_action_char; when "交換"; 0; when "調整"; 1; when "清掃";  2; else; nil; end
    corrected_datetime = checked_datetime unless corrective_action.nil?
    corrected_staff_code = staff_code unless corrective_action.nil?
    Result.create!(:check_id => check_data.id, :judgment => judgment, :measured_value => measured_value,
                   :abnormal_content => abnormal_content, :corrective_action => corrective_action,
                   :checked_datetime => checked_datetime, :corrected_datetime => corrected_datetime,
                   :staff_code => corrected_staff_code)
  end
end

# 対応・内容を登録する
#
def the_following_corrections_are_registered(table_str)
  cuke_table_rows(table_str).each do |inspection_id, check_sequence, corrective_action_char, corrective_content, staff_code, description|
    check = Check.find_by_inspection_id_and_sequence(inspection_id, check_sequence)
    return unless check
    corrective_action = case corrective_action_char; when "交換"; 0; when "調整"; 1; when "清掃";  2; else; nil; end

    check.result.update_attributes!(:corrective_action => corrective_action, :corrective_content => corrective_content,
                                    :corrected_datetime => DateTime.now,
                                    :staff_code => staff_code)
  end
end

# 最大文字列長のデータを登録する
#
def the_following_maxlength_data_are_registered(table_str)
  today = DateTime.now
  #                                  |件数   |工程名       |最長        |設備名         |最長          |周期        |部位名    |最長      |項目      |最長     |方法           |最長         |基準            |最長          |点検終了日(X日前)   |点検予定日(X日後)    |点検予定時(X時間後)|
  cuke_table_rows(table_str).each do |count, station_char, station_max, equipment_char, equipment_max, cycle_title, part_char, part_max, item_char, item_max, operation_char, operation_max, criterion_char, criterion_max, checked_date_before, scheduled_date_after, scheduled_time_after|
    count.to_i.times.each do |i|
      station = Station.find_or_create_by_name(station_max.to_i.times.collect{station_char}.to_s)
      equipment = Equipment.find_or_create_by_station_id_and_name(station.id, equipment_max.to_i.times.collect{equipment_char}.to_s)
      part = Part.find_or_create_by_equipment_id_and_sequence_and_name(equipment.id, i, part_max.to_i.times.collect{part_char}.to_s)

      cycle = Cycle.find_by_title(cycle_title)
      scheduled_datetime = today + scheduled_date_after.to_i + Rational(scheduled_time_after.to_i, 24)
      check_master = Check.create!(:cycle_id => cycle.id, :part_id => part.id, 
                                   :item => item_max.to_i.times.collect{item_char}.to_s, :sequence => i, :entry_type => 0, 
                                   :operation => operation_max.to_i.times.collect{operation_char}.to_s, 
                                   :criterion => criterion_max.to_i.times.collect{criterion_char}.to_s, 
                                   :scheduled_datetime => scheduled_datetime)

      check = check_master.make_child(i)
      checked_datetime = today - checked_date_before.to_i
      check.save_result_with_validation({:judgment => true, :checked_datetime => checked_datetime}, false)
      Inspection.find_or_create_by_staff_code_and_updated_at(:staff_code => "0123456", :updated_at => checked_datetime).checks << check
    end
  end
end