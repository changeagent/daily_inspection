Factory.define :part_for_view, :class => Part do |f|
  f.name "part_name"
end

Factory.define :check_for_header, :class => Check do |f|
  f.part { Factory.create(:part_for_view) }
  f.item "check_item"
  f.operation "check_operation"
  f.criterion "check_criterion"
  f.entry_type 0
  f.sequence(:sequence) {|n|n}
  f.scheduled_datetime {DateTime.now}
end

Factory.define :check_for_body, :class => Check do |f|
  f.part { Factory.create(:part_for_view) }
  f.item "check_item"
  f.operation "check_operation"
  f.criterion "check_criterion"
  f.entry_type 0
  f.sequence(:sequence) {|n|n}
  f.scheduled_datetime {DateTime.now}
end

Factory.define :check_for_view_with_normal_or_abnormal, :class => Check do |f|
  f.part { Factory.create(:part_for_view) }
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
end

Factory.define :check_for_view_with_measured_value, :class => Check do |f|
  f.part { Factory.create(:part_for_view) }
  f.entry_type 1
  f.scheduled_datetime {DateTime.now}
end

Factory.define :result_for_header, :class => Result do |f|
  f.judgment false
  f.measured_value 10.0
  f.abnormal_content "result_abnormal_content"
end

Factory.define :result_for_body, :class => Result do |f|
  f.judgment false
  f.measured_value 10.0
  f.abnormal_content "result_abnormal_content"
end
