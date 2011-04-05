Factory.define :cycle_for_equipment_show_list_of_result, :class => Cycle do |f|
  f.title "S"
  f.unit_type 0
  f.interval 4
end

Factory.define :equipment_for_equipment_show_list_of_result, :class => Equipment do |f|
end

Factory.define :part_for_equipment_show_list_of_result, :class => Part do |f|
  f.name "部位A"
end

Factory.define :check_parent_for_equipment_show_list_of_result, :class => Check do |f|
  f.item "項目A"
  f.scheduled_datetime DateTime.now
end

Factory.define :check_child_for_equipment_show_list_of_result, :class => Check do |f|
  f.item "check_child"
  f.entry_type 0
  f.scheduled_datetime DateTime.now
end

Factory.define :result_for_equipment_show_list_of_result_true, :class => Result do |f|
  f.judgment true
end

Factory.define :result_for_equipment_show_list_of_result_false, :class => Result do |f|
  f.judgment false
  f.abnormal_content "異常です。"
  f.corrective_action 0
end
