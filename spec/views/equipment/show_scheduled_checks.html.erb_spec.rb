require 'spec_helper'

describe "/equipment/show_scheduled_checks" do
  before do
    @parts_and_check_count = 2
    cycle = Factory.create(:cycle_for_equipment_show_scheduled_checks)
    @equipment = Factory.create(:equipment_for_equipment_show_scheduled_checks)
    parts = @parts_and_check_count.times.collect do |i|
      Factory.create(:part_for_equipment_show_scheduled_checks, :equipment_id => @equipment.id)
    end
    @scheduled_checks = assigns[:scheduled_checks] = parts.collect do |part|
      Factory.create(:check_for_equipment_show_scheduled_checks, :part_id => part.id, :cycle_id => cycle.id)
    end
    @scheduled_checks.each {|check| Factory.create(:result_for_equipment_show_scheduled_checks, :check_id => check.id)}
    params[:id] = @equipment.id
    render 'equipment/show_scheduled_checks'
  end

  it "'周期'、'部位 項目'、'前回結果'のラベルと、'メニューへ'ボタンが表示されること" do
    response.should have_tag('div#equipment_show_scheduled_checks') do
      with_tag('table#header') do
        with_tag('tr:nth-of-type(1)') do
          with_tag('td') do
            with_tag('form[action=?]', "/stations/operator_index")
            with_tag('input.controll_button[type=?][value=?]', "submit", t('stations_select'))
          end
        end
        with_tag('tr:nth-of-type(2)') do
          with_tag('th.cycle_title', t('activerecord.attributes.cycle.title'))
          with_tag('th.part_name', t('activerecord.attributes.part.name'))
          with_tag('th.check_item', t('activerecord.attributes.check.item'))
          with_tag('th.check_latest_judgment', t('activerecord.attributes.check.latest_judgment'))
        end
      end
    end
  end

  it "全ての点検データが表示された後に、'点検開始'ボタンが表示されること" do
    response.should have_tag('div#equipment_show_scheduled_checks') do
      with_tag('form[action=?]', "/equipment/start_inspection/#{@equipment.id}")
      with_tag('div#parts_and_checks') do
        with_tag('table#body') do
          @scheduled_checks.each_with_index do |check, i|
            with_tag("tr:nth-of-type(#{i+1})") do
              with_tag('td.cycle_title', check.cycle.title)
              with_tag('td.part_name', check.part.name)
              with_tag('td.check_item', check.item)
              with_tag('td.check_latest_judgment', Result::JUDGMENT_SYMBOLS[check.latest_judgment])
            end
          end
          without_tag("tr:nth-of-type(#{@scheduled_checks.size + 1})")
        end
        with_tag('table#footer') do
          with_tag('tr:nth-of-type(1)') do
            with_tag('td') do
              with_tag('input.controll_button[type=?][value=?]', "submit", t('equipments_start_inspection'))
            end
          end
        end
      end
    end
  end
end
