require 'spec_helper'

describe "/equipment/show_list_of_result" do
  before do
    @checks = []
    @parts_and_check_count = 2
    cycle = Factory.create(:cycle_for_equipment_show_list_of_result)
    @equipment = Factory.create(:equipment_for_equipment_show_list_of_result)
    parts = @parts_and_check_count.times.collect do |i|
      Factory.create(:part_for_equipment_show_list_of_result, :equipment_id => @equipment.id)
    end
    checks = parts.collect do |part|
      Factory.create(:check_parent_for_equipment_show_list_of_result, :part_id => part.id, :cycle_id => cycle.id)
    end
    checks.each do |check|
      chk = [check]
      7.times do
        cc = []
        3.times do |t|
          cc << check_child = Factory.create(:check_child_for_equipment_show_list_of_result, :parent_id => check.id)
          case t
          when 0
            Factory.create(:result_for_equipment_show_list_of_result_true, :check_id => check_child.id)
          when 1
            Factory.create(:result_for_equipment_show_list_of_result_false, :check_id => check_child.id)
          end
        end
        chk << cc
      end
      assigns[:checks] = @checks << chk
    end
    @today = assigns[:today] = DateTime.now
    render 'equipment/show_list_of_result'
  end

  it "'周期'、'部位'、'項目'のラベル、7日分の日付、'メニューへ'ボタンが表示されること" do
    response.should have_tag('div#equipment_show_list_of_result') do
      with_tag('table#menu') do
        with_tag('tr:nth-of-type(1)') do
          with_tag('td') do
            with_tag('form[action=?]', "/stations/ladder_index")
            with_tag('input.controll_button[type=?][value=?]', "submit", t('stations_select'))
          end
        end
      end
      with_tag('div#header_area') do
        with_tag('table#header') do
          with_tag('tr:nth-of-type(1)') do
            with_tag('th.cycle_title', t('activerecord.attributes.cycle.title'))
            with_tag('th.part_name', t('activerecord.attributes.part.name'))
            with_tag('th.check_item', t('activerecord.attributes.check.item'))
            (@checks[0].size - 1).times do |t|
              with_tag('th.check_date', (@today - (6 - t)).strftime("%m/%d"))
            end
          end
        end
      end
    end
  end

  it "'周期'、'部位'、'項目'、7日×3シフト分の'結果'が表示されること" do
    response.should have_tag('div#equipment_show_list_of_result') do
      with_tag('div#scroll_data_area') do
        with_tag('table#scroll_data') do
          @checks.each_with_index do |check, i|
            with_tag("tr:nth-of-type(#{i + 1})") do
              check.each_with_index do |chk, j|
                if j == 0
                  with_tag('td.cycle_title', check[0].cycle.title)
                  with_tag('td.part_name', check[0].part.name)
                  with_tag('td.check_item', check[0].item)
                else
                  chk.each do |c|
                    with_tag('td.check_shift', Result::JUDGMENT_SYMBOLS[c.judgment]) do
                      if c.judgment == false
                        with_tag("a", :attributes => {:href => "/corrections/show/#{c.id}"})
                      else
                        without_tag("a")
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
