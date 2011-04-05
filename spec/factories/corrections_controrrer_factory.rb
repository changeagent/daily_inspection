Factory.define :check_has_result_and_inspection, :class => Check do |f|
  f.inspection {Inspection.create(:staff_code => '0123456', :updated_at => DateTime.now)}
  f.part {Part.create(:equipment_id => 1)}
  f.parent_id 1
  f.entry_type 0
  f.result {Result.new}
  f.scheduled_datetime {DateTime.now}
end
