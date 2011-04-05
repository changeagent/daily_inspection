require 'spec_helper'

describe PagesController do
  describe "'portal'アクションのテスト" do
    before do
      get 'portal'
    end
    it "レイアウトファイルは使用せずに'pages/portal'をレンダリングすること" do
      response.should be_success
      response.layout.should == nil
      response.should render_template("pages/portal")
    end
  end
  describe "ルートページのテスト" do
    it ':controller => "pages", :action => "portal"がルートページ("/")に定義されていること' do
      route_for(:controller => "pages", :action => "portal").should == "/"
    end
  end
end