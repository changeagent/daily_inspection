Factory.define :inspection_has_check, :class => Inspection do
end

Factory.define :check_belong_to_inspection, :class => Check do |f|
  f.scheduled_datetime {DateTime.now}
end

Factory.define :inspection_for_update_action, :class => Inspection do
end

Factory.define :check_is_normal, :class => Check do |f|
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :cycle_has_normal_unit_type, :class => Cycle do |f|
  f.title "s"
  f.unit_type 0
  f.interval 4
end

Factory.define :check_has_valid_result, :class => Check do |f|
  f.cycle {Factory(:cycle_has_normal_unit_type)}
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
end

Factory.define :station_for_inspection_update_action, :class => Station do |f|
end
