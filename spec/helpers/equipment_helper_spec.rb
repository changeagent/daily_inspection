require 'spec_helper'

describe EquipmentHelper do

  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(EquipmentHelper)
  end

  context "点検内容IDと点検結果に応じて表示を切り替える場合" do
    before do
      @check_id = 1
    end
    it "ヘルパメソッドが存在すること" do
      helper.should be_respond_to("link_corrections_show")
    end
    it "点検結果が正常であれば'○'を表示すること" do
      helper.link_corrections_show(@check_id, true).should == Result::JUDGMENT_SYMBOLS[true]
    end
    it "点検結果が異常であれば'×'を表示し、異常対応確認入力画面へのリンクをつけること" do
      helper.link_corrections_show(@check_id, false).should ==
        "<a href=\"/corrections/show/#{@check_id}\">#{Result::JUDGMENT_SYMBOLS[false]}</a>"
    end
    it "点検結果が無ければ何も表示しないこと" do
      helper.link_corrections_show(@check_id, nil).should == Result::JUDGMENT_SYMBOLS[nil]
    end
    it "点検内容IDが無ければ何も表示しないこと" do
      helper.link_corrections_show(nil, nil).should be_nil
      helper.link_corrections_show(nil, true).should be_nil
      helper.link_corrections_show(nil, false).should be_nil
    end
  end

end
