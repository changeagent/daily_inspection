require 'spec_helper'

describe "/corrections/show" do

  share_examples_for "corrections_show_display" do
    it "ラベル名・データを表示すること" do
      response.should have_tag('div#corrections_show') do
        with_tag('table#header') do
          with_tag('tr') do
            with_tag('th.part_name', @check.part_name)
            with_tag('td') do
              with_tag('form[action=?]', "/equipment/show_list_of_result/#{@check.part.equipment_id}")
              with_tag('input.controll_button[type=?][value=?]', "submit", t('back_to_list'))
            end
          end
        end
        with_tag('form[action=?]', "/corrections/update/#{@check.id}") do
          with_tag('table#body') do
            with_tag('tr:nth-of-type(1)') do
              with_tag('th', t('activerecord.attributes.check.item'))
              with_tag('td.read_only', @check.item)
            end
            with_tag('tr:nth-of-type(2)') do
              with_tag('th', t('activerecord.attributes.check.operation'))
              with_tag('td.read_only', @check.operation)
            end
            with_tag('tr:nth-of-type(3)') do
              with_tag('th', t('activerecord.attributes.check.criterion'))
              with_tag('td.read_only', "#{@check.criterion}&nbsp;#{@check.limit_description}")
            end
            #点検結果欄('tr:nth-of-type(4)')の表示は、点検方式(選択or数値入力)によって
            #異なるため、別contextでテストする
            with_tag('tr:nth-of-type(5)') do
              with_tag('th', t('activerecord.attributes.inspection.staff_code'))
              with_tag('td.read_only', @check.inspection.staff_code)
            end
            with_tag('tr:nth-of-type(6)') do
              with_tag('th', t('activerecord.attributes.result.checked_datetime'))
              with_tag('td.read_only', @check.result.checked_datetime.strftime("%Y/%m/%d %H:%M:%S"))
            end
            with_tag('tr:nth-of-type(7)') do
              with_tag('th', t('activerecord.attributes.result.abnormal_content'))
              with_tag('td') do
                with_tag('input#correction_abnormal_content[type=?][maxlength=?][name=?][value=?]',
                  "text", 140, "correction[abnormal_content]", @check.result.abnormal_content)
              end
            end
            with_tag('tr:nth-of-type(8)') do
              with_tag('th', t('activerecord.attributes.result.corrective_action'))
              with_tag('td') do
                Result::CORRECTIVE_ACTION_VALUES.each_pair do |key, value|
                  with_tag("input#correction_corrective_action_#{value}[type=?][name=?][value=?]",
                    "radio", "correction[corrective_action]", value)
                  with_tag("label:nth-of-type(#{value+1})", t("activerecord.attributes.result.options_caption.#{key.downcase}"))
                end
              end
            end
            with_tag('tr:nth-of-type(9)') do
              with_tag('th', t('activerecord.attributes.result.corrective_content'))
              with_tag('td') do
                with_tag('input#correction_corrective_content[type=?][maxlength=?][name=?][value=?]',
                  "text", 140, "correction[corrective_content]", @check.result.corrective_content)
              end
            end
            with_tag('tr:nth-of-type(10)') do
              with_tag('th', t('activerecord.attributes.result.staff_code'))
              with_tag('td') do
                with_tag('input#correction_staff_code[type=?][maxlength=?][name=?][size=?][value=?]',
                  "text", 7, "correction[staff_code]", 11, @check.result.staff_code)
              end
            end
            with_tag('tr:nth-of-type(11)') do
              with_tag('th', t('activerecord.attributes.result.corrected_datetime'))
              with_tag('td') do
                with_tag('input#correction_corrected_datetime[type=?][maxlength=?][name=?][size=?][value=?]',
                  "text", 19, "correction[corrected_datetime]", 37, @check.result.corrected_datetime.strftime("%Y/%m/%d %H:%M:%S"))
              end
            end
          end
          with_tag('table#footer') do
            with_tag('tr') do
              with_tag('td') do
                with_tag('input.controll_button[type=?][value=?]', "submit", t('correspondence_completion'))
              end
            end
          end
        end
      end
    end
  end

  context "点検方式が正常/異常入力の場合" do
    before do
      @check = Factory.create(:check_for_corrections_show, :entry_type => 0)
      @check.save_result_with_validation(Factory.attributes_for(:result_for_corrections_show, {:judgment => false}), false)
      assigns[:check] = @check
      render 'corrections/show'
    end
    
    it_should_behave_like "corrections_show_display"

    it "点検結果欄に正常or異常を表示すること" do
      response.should have_tag('table#body') do
        with_tag('tr:nth-of-type(4)') do
          with_tag('th', t('activerecord.attributes.result.judgment'))
          if @check.result.judgment
            with_tag('td.read_only', t('activerecord.attributes.result.options_caption.normal'))
          else
            with_tag('td.read_only', t('activerecord.attributes.result.options_caption.abnormal'))
          end
        end
      end
    end
  end
  
  context "点検方式が測定値入力の場合" do
    before do
      @check = Factory.create(:check_for_corrections_show, :entry_type => 1)
      @check.save_result_with_validation(Factory.attributes_for(:result_for_corrections_show, {:measured_value => 25.0}), false)
      assigns[:check] = @check
      render 'corrections/show'
    end

    it_should_behave_like "corrections_show_display"
    
    it "点検結果欄に測定値と単位を表示すること" do
      response.should have_tag('table#body') do
        with_tag('tr:nth-of-type(4)') do
          with_tag('th', t('activerecord.attributes.result.judgment'))
          with_tag('td.read_only', @check.result.measured_value.to_s + "&nbsp;" + @check.unit_name)
        end
      end
    end
  end
end
