Factory.define :part_has_checks, :class => Part do |f|
  f.name "part_has_checks"
end

Factory.define :check_belongs_to_part, :class => Check do |f|
  f.item "check_belongs_to_part"
  f.scheduled_datetime DateTime.now
end

Factory.define :part_has_checks_spacified_scheduled_datetime, :class => Part do |f|
end

Factory.define :check_at_each_part_scheduled_at, :class => Check do |f|
  f.scheduled_datetime DateTime.now
end