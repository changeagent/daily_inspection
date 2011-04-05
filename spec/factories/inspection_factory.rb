Factory.define :inspection_valid_result_data, :class => Inspection do
end

Factory.define :check_has_valid_result_judgment_false, :class => Check do |f|
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
end

Factory.define :check_has_invalid_result, :class => Check do |f|
  f.inspection_id {Inspection.create.id}
  f.entry_type 1
  f.lower_limit 10.0
  f.upper_limit 20.0
  f.scheduled_datetime {DateTime.now}
end

Factory.define :check_has_not_been_checked, :class => Check do |f|
  f.inspection_id {Inspection.create.id}
  f.scheduled_datetime {DateTime.now}
end

Factory.define :inspection_has_checks, :class => Inspection do |f|
  f.checks {[Factory(:check_belongs_to_inspection_1st),Factory(:check_belongs_to_inspection_2nd)]}
end

Factory.define :check_belongs_to_inspection_1st, :class => Check do |f|
  f.scheduled_datetime {DateTime.now}
end

Factory.define :check_belongs_to_inspection_2nd, :class => Check do |f|
  f.scheduled_datetime {DateTime.now}
end

Factory.define :inspection_does_not_have_check, :class => Inspection do |f|
end

Factory.define :cycle_is_normal, :class => Cycle do |f|
  f.title "s"
  f.unit_type 0
  f.interval 4
end

Factory.define :check_has_normal_cycle, :class => Check do |f|
  f.cycle {Factory(:cycle_is_normal)}
  f.item "項目A"
  f.operation "方法B"
  f.criterion "基準C"
  f.entry_type 0
  f.unit_name "km/h"
  f.upper_limit 40
  f.lower_limit 60
  f.scheduled_datetime {DateTime.now}
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :inspection_has_normal_checks, :class => Inspection do |f|
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :check_is_normal1, :class => Check do |f|
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :check_is_normal2, :class => Check do |f|
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :cycle_is_abnormal, :class => Cycle do |f|
  f.title "s"
  f.interval 4
end

Factory.define :check_has_abnormal_cycle, :class => Check do |f|
  f.cycle {Factory(:cycle_is_abnormal)}
  f.item "項目A"
  f.operation "方法B"
  f.criterion "基準C"
  f.entry_type 0
  f.unit_name "km/h"
  f.upper_limit 40
  f.lower_limit 60
  f.scheduled_datetime {DateTime.now}
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :inspection_has_abnormal_checks, :class => Inspection do |f|
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :check_is_abnormal1, :class => Check do |f|
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :check_is_abnormal2, :class => Check do |f|
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
  f.updated_at {DateTime.now - Rational(10,24)}
end
