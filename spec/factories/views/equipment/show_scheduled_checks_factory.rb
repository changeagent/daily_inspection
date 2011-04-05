Factory.define :cycle_for_equipment_show_scheduled_checks, :class => Cycle do |f|
  f.title "S"
  f.unit_type 0
  f.interval 4
end

Factory.define :equipment_for_equipment_show_scheduled_checks, :class => Equipment do |f|
end

Factory.define :part_for_equipment_show_scheduled_checks, :class => Part do |f|
  f.name "pppart"
end

Factory.define :check_for_equipment_show_scheduled_checks, :class => Check do |f|
  f.item "cccheck"
  f.scheduled_datetime DateTime.now
end

Factory.define :result_for_equipment_show_scheduled_checks, :class => Result do |f|
 f.judgment true
end