# 点検期間拡張ライブラリ
require 'inspection_period'

class InspectionPeriod

  # inspection_periodインスタンスを生成する
  # 現在日時から任意の時間(9時間)を引いた時間から(点検期間日数-1)日前の9:00を点検期間の開始日時に設定する
  # === 引き数
  # *datetime*:: 現在日時
  # === 戻り値
  # inspection_periodインスタンス
  def initialize(datetime)
    start_datetime = datetime - Rational(9, 24) - (INTERVAL - 1)
    @start_datetime = DateTime.new(start_datetime.year, start_datetime.month, start_datetime.day, 9, 0, 0, Rational(9, 24))
  end

end