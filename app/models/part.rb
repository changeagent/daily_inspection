# Partsテーブルのモデル。
class Part < ActiveRecord::Base
  has_many :checks

  # 指定された日時に実施する点検一覧を返却する。
  # === 引き数
  # datetime 日時
  # === 戻り値
  # 点検一覧（Checkオブジェクトの配列）
  def scheduled_checks_at(datetime)
    Check.find(:all, 
               :include => [:part, :cycle],
               :conditions => ['parent_id is null and part_id=? and scheduled_datetime <= ?', self.id, datetime],
               :order => 'sequence asc')
  end
end
