require 'spec_helper'

describe "/inspections/final_confirm" do
  describe "'table id=body'のテスト" do

    share_examples_for "should be display staff_code and update_button" do
      it "'点検者氏名コード'ラベル・'点検者氏名コード'入力欄・'点検結果を保存する'ボタンを表示すること" do
        response.should have_tag('table#body') do
          with_tag('tr') do
            with_tag('th', t('activerecord.attributes.inspection.staff_code'))
            with_tag('td') do
              if @value_exist
                with_tag('input#inspection_staff_code[type=?][name=?][value=?][size=?][maxlength=?]',
                  "text", "inspection[staff_code]", @staff_code, 12, 7)
              else
                with_tag('input#inspection_staff_code[type=?][name=?][size=?][maxlength=?]',
                  "text", "inspection[staff_code]", 12, 7)
              end
              with_tag('input.controll_button[type=?][name=?][value=?]',
                "submit", "commit", t('update_inspection'))
            end
          end
        end
      end
    end

    context "点検の最終確認画面を表示する場合（DBに点検者氏名コードあり/sessionに氏名コードあり）" do
      before do
        @value_exist = true
        @inspection = assigns[:inspection] = Factory.build(:inspection_for_view, :staff_code => "staff01")
        @staff_code = @inspection.staff_code
        session[:staff_code] = "staff99"
        render 'inspections/final_confirm'
      end
      it_should_behave_like "should be display staff_code and update_button"
    end

    context "点検の最終確認画面を表示する場合（DBに点検者氏名コードなし/sessionに氏名コードあり）" do
      before do
        @value_exist = true
        @inspection = assigns[:inspection] = Factory.build(:inspection_for_view)
        @staff_code = session[:staff_code] = "staff99"
        render 'inspections/final_confirm'
      end
      it_should_behave_like "should be display staff_code and update_button"
    end

    context "点検の最終確認画面を表示する場合（DBに点検者氏名コードあり/sessionに氏名コードなし）" do
      before do
        @value_exist = true
        @inspection = assigns[:inspection] = Factory.build(:inspection_for_view, :staff_code => "staff01")
        @staff_code = @inspection.staff_code
        render 'inspections/final_confirm'
      end
      it_should_behave_like "should be display staff_code and update_button"
    end

    context "点検の最終確認画面を表示する場合（DBに点検者氏名コードなし/sessionに氏名コードなし）" do
      before do
        @value_exist = false
        @inspection = assigns[:inspection] = Factory.build(:inspection_for_view)
        @staff_code = @inspection.staff_code
        render 'inspections/final_confirm'
      end
      it_should_behave_like "should be display staff_code and update_button"
    end
  end
end
