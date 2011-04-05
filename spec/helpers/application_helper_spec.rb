require 'spec_helper'

describe ApplicationHelper do
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ApplicationHelper)
  end

  helper_name :application

  it "ヘルパメソッドが存在すること" do
    helper.should be_respond_to("uncheck_radio_button_js")
    helper.should be_respond_to("format_datetime")
  end

  it "uncheck_radio_button_jsメソッドの戻り値が意図するjavascriptであること" do
    helper.uncheck_radio_button_js('f1', 'r1').should == "javascript:radio_button=document.forms['f1'].r1;if(radio_button.checked==true){radio_button.checked=false;}else{radio_button.checked=true;}"
  end

  it "format_datetimeメソッドの戻り値が意図するフォーマットであること" do
    helper.format_datetime(DateTime.new(2010, 12, 15, 10, 00, 00)).should == "2010/12/15 10:00:00"
    helper.format_datetime(nil).should == nil
  end
end
