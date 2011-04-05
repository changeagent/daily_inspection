# Cyclesテーブルのモデル。
class Cycle < ActiveRecord::Base

  # 間隔の単位を表す定数（"時間" = 0, "ヶ月" = 1）
  UNIT_TYPES = {"HOURS" => 0, "MONTHS" => 1}

end
