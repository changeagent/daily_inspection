Factory.define :station_has_equipment, :class => Station do |f|
  f.equipment {[Factory(:equipment_belongs_to_station_1st), Factory(:equipment_belongs_to_station_2nd)]}
end

Factory.define :equipment_belongs_to_station_1st, :class => Equipment do |f|
end

Factory.define :equipment_belongs_to_station_2nd, :class => Equipment do |f|
end

Factory.define :station_does_not_have_equipment, :class => Station do |f|
end
