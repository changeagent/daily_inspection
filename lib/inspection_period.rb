# 点検期間を取り扱うクラス
# *start_datetime*:: 点検期間の開始日時
class InspectionPeriod
  attr_reader :start_datetime

  # 点検期間の日数
  INTERVAL = 7

  # inspection_periodインスタンスを生成する
  # 現在日時から(点検期間日数-1)日前の0:00を点検期間の開始日時に設定する
  # === 引き数
  # *datetime*:: 現在日時
  # === 戻り値
  # inspection_periodインスタンス
  def initialize(datetime)
    start_date = datetime - (INTERVAL - 1)
    @start_datetime = DateTime.new(start_date.year, start_date.month, start_date.day, 0, 0, 0, Rational(9, 24))
  end

  # 現在の点検期間開始日時から(点検期間日数*2-1)日後の日時を引き数として
  # 次期間のinspection_periodインスタンスを生成する
  # === 引き数
  # なし
  # === 戻り値
  # inspection_periodインスタンス
  def next_period
    InspectionPeriod.new(self.start_datetime + (INTERVAL * 2 - 1))
  end

end