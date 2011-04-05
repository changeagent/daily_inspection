# Checksテーブルのモデル。
class Check < ActiveRecord::Base
  belongs_to :part
  has_one :result
  belongs_to :cycle
  belongs_to :inspection

  # 点検方式を表す定数（"正常/異常を記入" = 0, "測定値を記入" = 1）
  ENTRY_TYPES = {"NORMAL_OR_ABNORMAL" => 0, "MEASURED_VALUE" => 1}


  # 次の点検内容（Checkクラスのインスタンス）を返却する。
  # === 引き数
  # なし
  # === 戻り値
  # 次の点検内容
  def next_check
    Check.find(:first,
      :conditions => ['inspection_id = ? and sequence > ?',
        self.inspection_id,
        self.sequence],
      :order => 'sequence ASC')
  end

  # 前の点検内容（Checkクラスのインスタンス）を返却する。
  # === 引き数
  # なし
  # === 戻り値
  # 前の点検内容
  def previous_check
    Check.find(:first,
      :conditions => ['inspection_id = ? and sequence < ?',
        self.inspection_id,
        self.sequence],
      :order => 'sequence DESC')
  end

  # 先頭の点検内容かチェックする。
  # === 引き数
  # なし
  # === 戻り値
  # *true*:: 先頭の点検内容の場合 / *false*:: 先頭の点検内容でない場合
  def first?
    self.previous_check.nil?
  end

  # 最後の点検内容かチェックする。
  # === 引き数
  # なし
  # === 戻り値
  # *true*:: 最後の点検内容の場合 / *false*:: 最後の点検内容でない場合
  def last?
    self.next_check.nil?
  end

  # 点検範囲の説明文字列を返却する。
  # === 引き数
  # なし
  # === 戻り値
  # 点検範囲の説明文字列
  def limit_description
    return "" if (self.lower_limit.blank? && self.upper_limit.blank?)
    return "～ #{self.upper_limit} #{self.unit_name}" if self.lower_limit.blank?
    return "#{self.lower_limit} #{self.unit_name} ～" if self.upper_limit.blank?
    return "#{self.lower_limit} ～ #{self.upper_limit} #{self.unit_name}"
  end

  # 点検結果を保存する。
  # === 引き数
  # *result_attributes*:: 点検結果を格納する配列（resultsテーブルのカラムを有する配列を指定すること）
  # *with_validation*:: 点検結果の検証有無 +true+ :検証する, +false+ :検証しない
  # === 戻り値
  # *true* 正常に保存できた場合 / *false* 正常に保存できなかった場合
  def save_result_with_validation(result_attributes, with_validation = true)
    # 点検結果の配列値をセットする
    self.result = Result.new unless self.result
    self.result.attributes = result_attributes
    # 点検結果を保存する
    self.result.save_with_validation(with_validation)
  end

  # マスタデータの次回点検日時を周期に応じて更新する。
  # === 引き数
  # なし
  # === 戻り値
  # *なし* 正常に保存できた場合 / *ActiveRecord::Rollback* 正常に保存できなかった場合
  def update_master_schedule!
    master = Check.find(:first, :include => [:cycle], :conditions => ['checks.id = ?', self.parent_id])
    unless master.update_scheduled_datetime
      raise ActiveRecord::RecordInvalid, master
    end
  end

  # 次回点検日時を周期に応じて更新する。
  # === 引き数
  # なし
  # === 戻り値
  # *true* 正常に保存できた場合 / *false* 正常に保存できなかった場合
  def update_scheduled_datetime
    case self.cycle.unit_type
    when Cycle::UNIT_TYPES["HOURS"]
      add_scheduled_datetime_by_hour(self.cycle.interval)
    when Cycle::UNIT_TYPES["MONTHS"]
      add_scheduled_datetime_by_month(self.cycle.interval)
    else
      errors.add_to_base :cannot_update_scheduled_datetime_because_cycle_was_invalid
      return false
    end
  end

  # 直近の完了済点検結果を取得する。
  # === 引き数
  # なし
  # === 戻り値
  # 直近の完了済点検結果(無い場合はnil)
  def latest_judgment
    latest_check.judgment unless latest_check.nil?
  end

  # 直近の完了済点検インスタンスを取得する。
  # === 引き数
  # なし
  # === 戻り値
  # 直近の完了済点検インスタンス(無い場合はnil)
  def latest_check
    Check.find(:first,
      :include => [:inspection],
      :conditions => ['checks.parent_id = ? and inspections.staff_code is NOT NULL', self.id],
      :order => 'scheduled_datetime DESC')
  end

  # 点検結果を取得する。
  # === 引き数
  # なし
  # === 戻り値
  # 点検結果(無い場合はnil)
  def judgment
    self.result.judgment unless self.result.nil?
  end

  # マスタデータから点検項目(子供)を作成する。
  # === 引き数
  # *sequence*:: 今回実施する点検で部位順、点検項目順にソートされた番号
  # === 戻り値
  # 点検項目(Checkオブジェクト)
  def make_child(sequence)
    check = Check.new(self.attributes)
    check.parent_id = self.id
    check.part_name = self.part.name
    check.cycle_id = nil
    check.cycle_title = self.cycle.title
    check.sequence = sequence
    check.save!
    return check
  end

  # マスタデータから指定期間内の点検結果一覧を取得する。
  # === 引数
  # *start_of_period*:: 期間の開始日時
  # *next_start_of_period*:: 次期間の開始日時
  # === 戻り値
  # 点検結果一覧（[[Checkオブジェクト, Checkオブジェクト, Checkオブジェクト], * 期間]の配列）
  def result_list_within_the_period(start_of_period, next_start_of_period)
    start_of_shift, j, list = start_of_period, 0, []
    InspectionPeriod::INTERVAL.times { list << [nil, nil, nil] }
    Check.find(:all,
      :include => [:inspection, :result],
      :conditions => ['parent_id = ? AND inspections.staff_code is not null AND inspections.updated_at >= ? AND inspections.updated_at < ?',
        self.id, start_of_period, next_start_of_period],
      :order => 'inspections.updated_at ASC').each do |check|
      while start_of_shift < next_start_of_period do
        if check.inspection.updated_at.to_datetime >= start_of_shift && check.inspection.updated_at.to_datetime < start_of_shift + Rational(8, 24)
          list[j / 3][j % 3] = check
          break
        end
        j += 1
        start_of_shift  += Rational(8, 24)
      end
    end
    return list
  end

  # 点検項目IDから点検項目データと紐付く点検データと点検結果データを取得する。
  # === 引数
  # *check_id*:: 点検項目ID
  # === 戻り値
  # 点検項目データ（Checkオブジェクト）
  def self.find_with_inspection_and_result_and_part(check_id)
    check = Check.find(:first,
      :include => [:inspection, :result, :part],
      :conditions => ['checks.id = ? AND checks.parent_id is not null AND inspections.staff_code is not null', check_id])
    raise ActiveRecord::RecordNotFound.new if check.nil?
    return check
  end

  private

  # 次回点検日時を時間で更新する。
  # === 引き数
  # *hour*:: 追加する時間
  # === 戻り値
  # *true* 正常に保存できた場合 / *false* 正常に保存できなかった場合
  def add_scheduled_datetime_by_hour(hour)
    self.update_attributes(:scheduled_datetime =>
        self.scheduled_datetime.to_datetime + Rational(hour, 24))
  end

  # 次回点検日時を月で更新する。
  # === 引き数
  # *month*:: 追加する月
  # === 戻り値
  # *true* 正常に保存できた場合 / *false* 正常に保存できなかった場合
  def add_scheduled_datetime_by_month(month)
    self.update_attributes(:scheduled_datetime =>
        self.scheduled_datetime.to_datetime >> month)
  end

end
