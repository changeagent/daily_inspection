Given /^以下の点検内容を含む点検を開始している:$/ do |table|
  table.rows.each do |part_name, item, operation, criterion, lower_limit, upper_limit, unit_name, sequence|
    part = Part.find_by_name(part_name) || Part.create!(:name => part_name)
    entry_type = Check::ENTRY_TYPES["MEASURED_VALUE"]
    part.checks << check_data = Check.create!(:part_name => part_name, :item => item, :operation => operation,
      :criterion => criterion, :lower_limit => lower_limit, :upper_limit => upper_limit, :unit_name => unit_name,
      :sequence => sequence, :scheduled_datetime => DateTime.now, :entry_type => entry_type)
    inspection = Inspection.find_by_staff_code("staff99") || Inspection.create!(:staff_code => "staff99")
    inspection.checks << check_data
  end
end

When /^"(.*)"番目の点検内容を"(.*)"画面に表示する$/ do |order, page_name|
  sequence = order.to_i - 1
  check = Check.find_by_sequence(sequence)
  visit path_to(page_name) + "/" + check.id.to_s
end

Then /^以下の点検内容を表示していること:$/ do |table|
  table.transpose.rows.each do |data_name, value|
    unless (value == "(空白)" || value == "(未選択)")
      return false unless response.body.should =~ Regexp.union(value)
    end
  end
end

When /^"点検結果"に"(.*)"を入力する$/ do |value|
  fill_in("result_measured_value", :with => value)
end

When /^前へボタンをクリックする$/ do
  pending # 「前へ」ボタンは Javascript（button_to_function）を用いた機能のため、目視で確認すること。
end

Then /^"異常内容を入力してください"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end