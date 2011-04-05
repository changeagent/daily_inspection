Factory.define :result_for_corrections_show, :class => Result do |f|
  f.checked_datetime DateTime.now
  f.abnormal_content "異常内容E"
  f.corrective_content "対応内容F"
  f.staff_code "staff02"
  f.corrected_datetime DateTime.now
  f.corrective_action 1
end

Factory.define :check_for_corrections_show, :class => Check do |f|
  f.part {Part.create(:equipment_id => 100)}
  f.inspection {Inspection.create(:staff_code => 'staff01')}
  f.result {Result.new}
  f.part_name "部位A"
  f.item "項目B"
  f.operation "方法C"
  f.criterion "基準D"
  f.upper_limit 50.0
  f.lower_limit 100.0
  f.unit_name "ml/min"
  f.scheduled_datetime DateTime.now
end
