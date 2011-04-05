require 'spec_helper'

describe "/checks/show" do
  describe "'table id=header'のテスト" do
    context "2件目以降の点検の場合" do
      before do
        inspection_id = Check.maximum(:inspection_id).to_i + 1
        Factory.create(:check_for_header, :inspection_id => inspection_id)
        @check = assigns[:check] = Factory.create(:check_for_header, :inspection_id => inspection_id)
        @result = assigns[:result] = Factory.create(:result_for_header, :check_id => @check.id)
        render 'checks/show'
      end
      
      it "「前へ」「次へ」ボタン・部位欄が表示されていること " do
        response.should have_tag('table#header') do
          with_tag('th') do
            with_tag('input.controll_button[type=?][value=?]', "button", t('prev'))
          end
          with_tag('td', @check.part.name)
          with_tag('th') do
            with_tag('input.controll_button[type=?][name=?][value=?]', "submit", "commit", t('next'))
          end
        end
      end
    end
  
    context "1件目の点検の場合" do
      before do
        @check = assigns[:check] = Factory.create(:check_for_header)
        @result = assigns[:result] = Factory.create(:result_for_header, :check_id => @check.id)
        render 'checks/show'
      end

      it "「前へ」ボタンが表示されていないこと" do
        response.should have_tag('table#header') do
          with_tag('th') do
            without_tag('input.controll_button[value=?]', t('prev'))
          end
        end
      end
    end
  end
  
  describe "'table id=body'のテスト" do
    context "データ内容の影響を受けない共通部分の場合" do
      before do
        @check = assigns[:check] = Factory.create(:check_for_body)
        @result = assigns[:result] = Factory.create(:result_for_body, :check_id => @check.id)
        render 'checks/show'
      end
      
      it "ラベル名・データを表示すること" do
        response.should have_tag('table#body') do
          with_tag('tr:nth-of-type(1)') do
            with_tag('th', t('activerecord.attributes.check.item'))
            with_tag('td', @check.item)
          end
          with_tag('tr:nth-of-type(2)') do
            with_tag('th', t('activerecord.attributes.check.operation'))
            with_tag('td', @check.operation)
          end
          with_tag('tr:nth-of-type(3)') do
            with_tag('th', t('activerecord.attributes.check.criterion'))
            with_tag('td', "#{@check.criterion}&nbsp;")
          end
          with_tag('tr:nth-of-type(5)') do
            with_tag('th', t('activerecord.attributes.result.abnormal_content'))
            with_tag('input#result_abnormal_content[type=?][name=?][size=?][maxlength=?][value=?]',
              "text", "result[abnormal_content]", 150, 140, @result.abnormal_content)
          end
          with_tag('tr:nth-of-type(6)') do
            with_tag('th', t('activerecord.attributes.result.corrective_action'))
            with_tag('td') do
              Result::CORRECTIVE_ACTION_VALUES.each_pair do |key, value|
                with_tag("input#result_corrective_action_#{value}[type=?][name=?][value=?]",
                  "radio", "result[corrective_action]", value)
                with_tag("label:nth-of-type(#{value+1})", t("activerecord.attributes.result.options_caption.#{key.downcase}"))
              end
            end
          end
        end
      end
    end

    context "点検結果を正常・異常で選択する場合" do
      before do
        @check = assigns[:check] = Factory.create(:check_for_view_with_normal_or_abnormal)
        @result = assigns[:result] = Factory.create(:result_for_body, :check_id => @check.id)
        render 'checks/show'
      end

      it "ラジオボタンを表示すること" do
        response.should have_tag('table#body') do
          with_tag('tr:nth-of-type(4)') do
            with_tag('th', t('activerecord.attributes.result.judgment'))
            with_tag('td') do
              with_tag('input#result_judgment_true[type=?][name=?][value=?]', "radio", "result[judgment]", true)
              with_tag('label:nth-of-type(1)', t('activerecord.attributes.result.options_caption.normal'))
              with_tag('input#result_judgment_false[type=?][name=?][value=?]', "radio", "result[judgment]", false)
              with_tag('label:nth-of-type(2)', t('activerecord.attributes.result.options_caption.abnormal'))
            end
          end
        end
      end
    end
    
    context "点検結果を数値で入力する場合" do
      before do
        @check = assigns[:check] = Factory.create(:check_for_view_with_measured_value)
        @result = assigns[:result] = Factory.create(:result_for_body, :check_id => @check.id)
        render 'checks/show'
      end

      it "数値入力欄を表示すること" do
        response.should have_tag('table#body') do
          with_tag('tr:nth-of-type(4)') do
            with_tag('th', t('activerecord.attributes.result.judgment'))
            with_tag('td') do
              with_tag('input#result_measured_value[type=?][maxlength=?][size=?][value=?]',
                "text", 10, 11, @result.measured_value)
            end
          end
        end
      end
    end
  end
end
