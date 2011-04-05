When /^異常内容に"(.*)"と入力する$/ do |value|
  fill_in("correction_abnormal_content", :with => value)
end

# MEMO: 未選択の状態は、JavaScriptを用いた機能のため、現時点ではpendingとして扱う
When /^対応・処置で"(.*)"を選択する$/ do |value|
  case value
  when "交換"
    choose("correction_corrective_action_0")
  when "調整"
    choose("correction_corrective_action_1")
  when "清掃"
    choose("correction_corrective_action_2")
  when ""
    pending # JavaScriptを用いた機能のため、目視で確認すること。
  end
end

When /^対応内容に"(.*)"と入力する$/ do |value|
  fill_in("correction_corrective_content", :with => value)
end

When /^対応者氏名コードに"(.*)"と入力する$/ do |value|
  fill_in("correction_staff_code", :with => value)
end

When /^対応日時に"(.*)"と入力する$/ do |value|
  fill_in("correction_corrected_datetime", :with => value)
end

Then /^点検ID"(.*)"、点検順"(.*)"の"(.*)"画面を再度表示すること$/ do |inspection_id, sequence, page_name|
  check_id = Check.find_by_inspection_id_and_sequence(inspection_id, sequence).id
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == "/corrections/update/" + check_id.to_s
  else
    assert_equal "/corrections/update/" + check_id.to_s, current_path
  end
end

# MEMO: アラートメッセージ表示確認のstepsは1つにまとめ、passion_steps.rbに記述したほうがよい
#Then /^"(.*)"とアラートメッセージが表示されること$/ do |value|
#  pending # JavaScriptを用いた機能のため、目視で確認すること。
#end
Then /^"対応・処置を選択してください"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end

Then /^"対応内容を入力してください"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end

Then /^"対応者氏名コードを入力してください"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end

Then /^"対応者氏名コードは半角英数7文字で入力してください"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end

Then /^"対応日時を入力してください"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end

Then /^"対応日時には日付、時間を入力してください"とアラートメッセージが表示されること$/ do
  pending # JavaScriptを用いた機能のため、目視で確認すること。
end
