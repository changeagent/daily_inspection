# Passion Step Definisions

Given /^現在の日時が、"(.*)"である$/ do |datetime|
  DateTime.class_eval %Q{
    def self.now
      return DateTime.parse("#{datetime}")
    end
  }
end

Given /^"(.*)"画面が表示されている$/ do |page_name|
  visit path_to(page_name)
end

When /^"(.*)"画面を表示する$/ do |page_name|
  visit path_to(page_name)
end

And /^"(.*)"画面を表示している$/ do |page_name|
  visit path_to(page_name)
end

Then /^"(.*)"画面を表示すること$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^以下の"工程"が一覧で表示されていること:$/ do |expected|
  expected.diff!(tableish('table tr.station_row', 'td:first-child'))
end

Then /^工程名の下に以下の"設備名"が表示されていること:$/ do |expected|
  expected.diff!(tableish('table tr.equipment_row', 'td'))
end
