When /^以下の点検内容のマスタデータと今回の点検結果が登録された状態で"点検者入力"画面を表示する:$/ do |table|
  inspection = Inspection.create!()
  table.rows.each do |equipment_name, cycle_title, part_name, part_sequence, item, sequence, scheduled_datetime, thistime_judgment, index|
    equipment = Equipment.find_by_name(equipment_name) || Equipment.create(:name => equipment_name)
    equipment.parts << part = Part.find_by_name_and_equipment_id(part_name, equipment.id) || Part.create!(:name => part_name, :sequence => part_sequence)
    part.checks << check_master = Check.create!(:item => item, :sequence => sequence, :cycle_id => Cycle.find_by_title(cycle_title).id, :scheduled_datetime => DateTime.parse(scheduled_datetime.to_s))
    judgment = case thistime_judgment; when "○"; true; when "×"; false; else; nil; end
    check_data = check_master.make_child(index)
    check_data.save_result_with_validation({:judgment => judgment}, false)
    inspection.checks << check_data
  end

  visit path_to("点検者入力") + "/" + inspection.id.to_s
end

Then /^点検内容のマスタデータにある次回点検日時が以下の通り更新されていること:$/ do |table|
  table.rows.each do |equipment_name, cycle_title, part_name, part_sequence, item, sequence, scheduled_datetime, increment|
    equipment = Equipment.find_by_name(equipment_name)
    part = Part.find(:first, :conditions => ['name = ? and sequence = ? and equipment_id = ?', part_name, part_sequence, equipment.id])
    cycle = Cycle.find_by_title(cycle_title)
    check = Check.find(:first, :conditions => ['part_id = ? and item = ? and sequence = ? and cycle_id = ?', part.id, item, sequence, cycle.id] )

    check.scheduled_datetime.should == Time.parse(scheduled_datetime)
  end
end