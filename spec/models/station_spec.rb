require 'spec_helper'

describe Station do
  describe "equipmentテーブルとの関連付けのテスト" do
    context "equipmentテーブルに関連するレコードが存在する場合" do
      before do
        @station = Factory.create(:station_has_equipment)
      end
      it "equipmentメソッドでequipmentインスタンスを要素にもつ配列を取得すること" do
        @station.equipment.should have(2).items
        @station.equipment[0].should be_instance_of Equipment
        @station.equipment[1].should be_instance_of Equipment
      end
    end
    context "equipmentテーブルに関連するレコードが存在しない場合" do
      before do
        @station = Factory.create(:station_does_not_have_equipment)
      end
      it "equipmentメソッドで空の配列を取得すること" do
        @station.equipment.should have(0).items
        @station.equipment[0].should be_nil
      end
    end
  end
end
