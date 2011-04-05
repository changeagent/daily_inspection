require 'spec_helper'

describe ChecksController do

  describe "'show/:id'アクションのテスト" do

    context "resultデータがある場合" do
      before do
        @check = Factory.create(:check_has_result_in_controller)
        get 'show', :id => @check.id
      end

      it "checkデータが取得できること" do
        assigns[:check].should == @check
      end

      it "取ってきたデータは、checkモデルのインスタンスであること" do
        assigns[:check].should be_instance_of Check
      end

      it "リクエストパラメタで指定されたresultデータであること" do
        assigns[:result].id.should == @check.result.id
      end

      it "取ってきたデータは、resultモデルのインスタンスであること" do
        assigns[:result].should be_instance_of Result
      end

      it { response.should be_success }
      it { response.should render_template("checks/show") }
    end

    context "resultデータがない場合" do
      before do
        @check = Factory.create(:check_does_not_have_result_in_controller)
        get 'show', :id => @check.id
      end

      it "checkデータが取得できること" do
        assigns[:check].should == @check
      end

      it "新しいresultが作成されること" do
        assigns[:result].check_id == @check.id
      end

      it "作成されたデータは、resultモデルのインスタンスであること" do
        assigns[:result].should be_instance_of Result
      end

      it { response.should be_success }
      it { response.should render_template("checks/show") }
    end
  end

  describe "「次へ」「前へ」の遷移テスト" do
    def create_sequential_checks
      # 連続した点検内容データ
      inspection_id = Check.maximum(:inspection_id).to_i + 1
      @sequential_checks = {:first => Factory.create(:check_of_sequentially_in_controller,
                                                     :inspection_id => inspection_id),
                            :middle => Factory.create(:check_of_sequentially_in_controller,
                                                      :inspection_id => inspection_id),
                            :last => Factory.create(:check_of_sequentially_in_controller,
                                                    :inspection_id => inspection_id)}
      # 点検結果を格納したリクエストパラメータ（Hash）
      @result = Factory.attributes_for(:result_of_request_parameter)
    end

    def destroy_sequential_checks
      @sequential_checks.each_value {|check|check.destroy}
    end

    # 点検結果が更新されていることを確認する共通のexample
    share_examples_for "check_result_should_be_saved" do
      it "@check.resultの値がリクエストパラメータ':result'の値で更新されていること" do
        check_result = assigns[:check].result
        check_result.measured_value.should == @result[:measured_value]
        check_result.judgment.should == @result[:judgment]
        check_result.abnormal_content.should == @result[:abnormal_content] unless @result[:judgment]
        check_result.corrective_action.should == @result[:corrective_action] unless @result[:judgment]
      end
    end

    describe "'next/:id'アクション(次への遷移)のテスト" do

      before(:all) do
        create_sequential_checks
      end

      after(:all) do
        destroy_sequential_checks
      end

      context "最初の点検データ(sequential_first)で実行した場合" do

        before do
          post 'next', :id => @sequential_checks[:first].id, :result => @result
        end

        it "インスタンス変数@checkに、@sequential_checks[:first]の値がセットされること" do
          assigns[:check].should == @sequential_checks[:first]
        end

        it_should_behave_like "check_result_should_be_saved"

        it { response.should be_redirect }

        it "showアクションに'次のID'でリダイレクトされること" do
          response.should redirect_to(:action => 'show', :id => @sequential_checks[:middle].id)
        end
      end

      context "最後の点検データ(@sequential_checks[:last])で実行した場合" do

        before do
          post 'next', :id => @sequential_checks[:last].id, :result => @result
        end

        it "インスタンス変数@checkに、@sequential_checks[:last]の値がセットされること" do
          assigns[:check].should == @sequential_checks[:last]
        end

        it_should_behave_like "check_result_should_be_saved"

        it { response.should be_redirect }

        it "点検結果の最終確認画面にリダイレクトすること" do
          response.should redirect_to(:controller => 'inspections',
                                      :action => 'final_confirm',
                                      :id => @sequential_checks[:last].inspection_id)
        end

      end

    end

    describe "'previous/:id'アクション(前への遷移)のテスト" do

      before(:all) do
        create_sequential_checks
      end

      after(:all) do
        destroy_sequential_checks
      end

      context "最初の点検データ(sequential_first)で実行した場合" do

        before do
          post 'previous', :id => @sequential_checks[:first].id, :result => @result
        end

        it "インスタンス変数@checkに、@sequential_checks[:first]の値がセットされること" do
          assigns[:check].should == @sequential_checks[:first]
        end

        it_should_behave_like "check_result_should_be_saved"

        it { response.should be_redirect }

        it "ルートページにリダイレクトされること" do
          response.should redirect_to("/")
        end
      end

      context "最後の点検データ(@sequential_checks[:last])で実行した場合" do

        before do
          post 'previous', :id => @sequential_checks[:last].id, :result => @result
        end

        it "インスタンス変数@checkに、@sequential_checks[:last]の値がセットされること" do
          assigns[:check].should == @sequential_checks[:last]
        end

        it_should_behave_like "check_result_should_be_saved"

        it { response.should be_redirect }

        it "showアクションで'前のID'の点検入力画面にリダイレクトされること" do
          response.should redirect_to(:action => 'show', :id => @sequential_checks[:middle].id)
        end
      end
    end
  end

  describe "適切でない点検結果の入力テスト" do

    before(:all) do
      # テストデータの作成
      inspection_id = Check.maximum(:inspection_id).to_i + 1
      @two_checks = {:first => Factory.create(:check_of_sequentially_in_controller,
                                              :inspection_id => inspection_id),
                     :last => Factory.create(:check_of_sequentially_in_controller,
                                             :inspection_id => inspection_id)}
      @invalid_request = Factory.attributes_for(:result_of_invalid_request_paramter)
    end

    after(:all) do
      @two_checks.each_value {|check|check.destroy}
    end

    context "'next/:id'アクション(次への遷移)の場合" do
      before do
        seq_check = @two_checks[:first]
        seq_check.result ||= Factory.build(:result_init_instance)
        post 'next', :id => seq_check.id, :result => @invalid_request
      end

      it "インスタンス変数に、点検内容(check)・点検結果(Result)の値がセットされること" do
        assigns[:check].should == @two_checks[:first]
        assigns[:result].should be_instance_of Result
      end

      it "点検結果が保存されていないこと" do
        Result.count(:conditions => ['check_id=?', @two_checks[:first].id]).should == 0
      end

      it "点検画面が表示されること" do
        response.should be_success
        response.should render_template("checks/show")
      end
    end

    context "'previous/:id'アクション(前への遷移)の場合" do
      before do
        @two_checks[:last].result ||= Factory.build(:result_init_instance)
        post 'previous', :id => @two_checks[:last].id, :result => @invalid_request
      end

      it "点検結果が保存されていること" do
        assigns[:check].result.should_not be_nil
        Result.count(:conditions => ['check_id=?', @two_checks[:last].id]).should == 1
      end

      it "showアクションに'前のID'でリダイレクトされること" do
        response.should be_redirect
      end

      it "showアクションで'前のID'の点検入力画面にリダイレクトされること" do
        response.should redirect_to(:action => 'show', :id => @two_checks[:first].id)
      end
    end
  end
end