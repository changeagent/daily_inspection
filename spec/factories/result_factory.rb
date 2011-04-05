Factory.define :result_has_check, :class => Result do |f|
  f.measured_value 10
  f.check {Check.create(:scheduled_datetime => DateTime.now)}
end

Factory.define :check_entry_type_is_measured_value, :class => Check do |f|
  f.entry_type 1
  f.lower_limit 10.00
  f.upper_limit 20.00
  f.scheduled_datetime {DateTime.now}
end

Factory.define :result_measured_value_is_smaller_than_lower_limit, :class => Result do |f|
  f.measured_value 9.9999
  f.check { Factory(:check_entry_type_is_measured_value) }
end

Factory.define :result_measured_value_is_equal_lower_limit, :class => Result do |f|
  f.measured_value 10.00
  f.check { Factory(:check_entry_type_is_measured_value) }
end

Factory.define :result_measured_value_is_larger_than_lower_limit_withiout_upper_limit, :class => Result do |f|
  f.measured_value 25.00
  f.check {Check.create(:entry_type => 1, :lower_limit => 10.00, :scheduled_datetime => DateTime.now)}
end

Factory.define :result_measured_value_is_in_range, :class => Result do |f|
  f.measured_value 15.00
  f.check { Factory(:check_entry_type_is_measured_value) }
end

Factory.define :result_measured_value_is_smaller_than_upper_limit_without_lower_limit, :class => Result do |f|
  f.measured_value 5.00
  f.check {Check.create(:entry_type => 1, :upper_limit => 20.00, :scheduled_datetime => DateTime.now)}
end

Factory.define :result_measured_value_is_equal_upper_limit, :class => Result do |f|
  f.measured_value 20.00
  f.check { Factory(:check_entry_type_is_measured_value) }
end

Factory.define :result_measured_value_is_larger_than_upper_limit, :class => Result do |f|
  f.measured_value 20.0001
  f.check { Factory(:check_entry_type_is_measured_value) }
end

Factory.define :result_measured_value_is_nil, :class => Result do |f|
  f.check { Factory(:check_entry_type_is_measured_value) }
end

Factory.define :check_has_result_with_entry_type_0, :class => Check do |f|
  f.entry_type 0
  f.result {Result.new}
  f.scheduled_datetime {DateTime.now}
end

Factory.define :result_is_selected_true_with_abnormal_content, :class => Result do |f|
  f.judgment true
  f.abnormal_content "異常内容を入力しました。"
end

Factory.define :result_is_selected_true_with_corrective_action, :class => Result do |f|
  f.judgment true
  f.corrective_action 0
end

Factory.define :result_is_selected_false_with_abnormal_content_under_140chars_multibyte, :class => Result do |f|
  f.judgment false
  f.abnormal_content "これは異常内容です１これは異常内容です２これは異常内容です３これは異常内容です４これは異常内容です５これは異常内容です６これは異常内容です７これは異常内容です８これは異常内容です９これは異常内容です０これは異常内容です１これは異常内容です２これは異常内容です３これは異常内容です４"
  f.corrective_action 1
end

Factory.define :result_is_selected_false_with_abnormal_content_over_140chars_multibyte, :class => Result do |f|
  f.judgment false
  f.abnormal_content "これは異常内容です１これは異常内容です２これは異常内容です３これは異常内容です４これは異常内容です５これは異常内容です６これは異常内容です７これは異常内容です８これは異常内容です９これは異常内容です０これは異常内容です１これは異常内容です２これは異常内容です３これは異常内容です４こ"
end

Factory.define :result_is_selected_false_with_abnormal_content_under_140chars_singlebyte, :class => Result do |f|
  f.judgment false
  f.abnormal_content "abnormal!1abnormal!2abnormal!3abnormal!4abnormal!5abnormal!6abnormal!7abnormal!8abnormal!9abnormal!0abnormal!1abnormal!2abnormal!3abnormal!4"
end

Factory.define :result_is_selected_false_with_abnormal_content_over_140chars_singlebyte, :class => Result do |f|
  f.judgment false
  f.abnormal_content "abnormal!1abnormal!2abnormal!3abnormal!4abnormal!5abnormal!6abnormal!7abnormal!8abnormal!9abnormal!0abnormal!1abnormal!2abnormal!3abnormal!4a"
end

Factory.define :result_is_selected_false_without_abnormal_content, :class => Result do |f|
  f.judgment false
end

Factory.define :result_is_not_selected_judgment, :class => Result do
end

Factory.define :check_has_result_with_entry_type_1, :class => Check do |f|
  f.entry_type 1
  f.lower_limit 10.00
  f.upper_limit 30.00
  f.result {Result.new}
  f.scheduled_datetime {DateTime.now}
end

Factory.define :check_has_result_dummy, :class => Check do |f|
  f.entry_type 1
  f.lower_limit -8888.8888
  f.upper_limit -2222.2222
  f.result {Result.new()}
  f.scheduled_datetime {DateTime.now}
end

Factory.define :result_is_enterd_true, :class => Result do |f|
  f.measured_value 20.00
end

Factory.define :result_is_enterd_true_for_update, :class => Result do |f|
  f.measured_value 25.00
end

Factory.define :result_is_enterd_true_with_abnormal_content, :class => Result do |f|
  f.measured_value 20.00
  f.abnormal_content "異常内容を入力しました。"
end

Factory.define :result_is_enterd_true_with_corrective_action, :class => Result do |f|
  f.measured_value 20.00
  f.corrective_action 1
end

Factory.define :result_is_enterd_false_with_abnormal_content_under_140chars_multibyte, :class => Result do |f|
  f.measured_value 100.0
  f.abnormal_content "異常内容を入力しました。"
  f.corrective_action 2
end

Factory.define :result_is_enterd_false_with_abnormal_content_over_140chars_singlebyte, :class => Result do |f|
  f.measured_value 1.00
  f.abnormal_content "abnormal!1abnormal!2abnormal!3abnormal!4abnormal!5abnormal!6abnormal!7abnormal!8abnormal!9abnormal!0abnormal!1abnormal!2abnormal!3abnormal!4a"
end

Factory.define :result_is_enterd_false_without_abnormal_content, :class => Result do |f|
  f.measured_value 1.00
end

Factory.define :result_is_not_enterd_measured_value, :class => Result do
end

Factory.define :result_is_enterd_character_into_measured_value, :class => Result do |f|
  f.measured_value "測定値に文字列を入力しました。"
end

Factory.define :result_is_enterd_true_with_measured_value_over_digit, :class => Result do |f|
  f.measured_value 20.00001
end

Factory.define :cycle_is_normal_for_set_staff_code, :class => Cycle do |f|
  f.title "s"
  f.unit_type 0
  f.interval 4
end

Factory.define :check_has_normal_cycle_for_set_staff_code, :class => Check do |f|
  f.cycle {Factory(:cycle_is_normal_for_set_staff_code)}
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

Factory.define :inspection_has_normal_check_for_set_staff_code, :class => Inspection do |f|
  f.staff_code "staff01"
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :check_is_normal_for_set_staff_code, :class => Check do |f|
  f.entry_type 0
  f.scheduled_datetime {DateTime.now}
  f.updated_at {DateTime.now - Rational(10,24)}
end

Factory.define :check_has_result_with_checked_datetime_and_corrected_datetime, :class => Check do |f|
  f.entry_type 0
  f.result {Result.new({:checked_datetime => DateTime.now - Rational(1, 24), :corrected_datetime => DateTime.now - Rational(1, 24), :abnormal_content => "異常内容"})}
  f.scheduled_datetime {DateTime.now}
end

Factory.define :result_for_validation_check_before_update_correction, :class => Result do |f|
  f.check {Check.new({:entry_type => 0, :scheduled_datetime => DateTime.now})}
  f.judgment false
  f.abnormal_content "異常内容テキスト"
end