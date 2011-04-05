# Stationsテーブルのモデル。
class Station < ActiveRecord::Base
  has_many :equipment
end
