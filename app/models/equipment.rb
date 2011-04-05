# Equipmentテーブルのモデル。
class Equipment < ActiveRecord::Base
  has_many :parts

  # 指定された設備の点検予定を返却する。
  # === 引き数
  # *id*:: 設備ID
  # *datetime*:: 日時
  # === 戻り値
  # 点検予定（Checkオブジェクトを要素に持つ配列）
  def self.scheduled_checks(id, datetime)
    Part.find(:all, :conditions => ['equipment_id=?', id], :order => 'sequence asc').collect do |part|
      part.scheduled_checks_at(datetime)
    end.flatten
  end

  # 設備に属する点検マスタデータから実施する点検項目を作成する。
  # === 引き数
  # *id*:: 設備ID
  # *datetime*:: 日時
  # === 戻り値
  # 最初に実施する点検ID
  def self.start_inspection(id, datetime)
    ActiveRecord::Base::transaction() do
      inspection = Inspection.create
      self.scheduled_checks(id, datetime).each_with_index do |check, i|
        inspection.checks << check.make_child(i)
      end
      return inspection.checks.first.id
    end
  rescue
    return nil
  end

  # 対象設備の点検結果から1週間分の結果をまとめたデータを作成する
  # === 引き数
  # *id*:: 設備ID
  # *datetime*:: 起点となる日時
  # === 戻り値
  # 周期・部位・項目および期間中の点検結果(Checkインスタンス)の配列
  def self.list_of_result(id, datetime)
    inspection_period = InspectionPeriod.new(datetime)
    self.find(id).check_masters.collect do |check_master|
      [check_master] + check_master.result_list_within_the_period(inspection_period.start_datetime,
                                                                  inspection_period.next_period.start_datetime)
    end
  end

  # 設備の点検内容(点検マスタ)を取得する
  # === 引き数
  # なし
  # === 戻り値
  # 点検内容(Checkオブジェクトを要素に持つ配列)
  def check_masters
    Check.find(:all, 
               :include => [:part, :cycle],
               :conditions => ['parts.equipment_id = ? and parent_id is ?', self.id, nil],
               :order => 'parts.sequence ASC, checks.sequence ASC')
  end
end
