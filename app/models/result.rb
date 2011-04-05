# Resultsテーブルのモデル。
class Result < ActiveRecord::Base
  belongs_to :check

  # 対処・処置を表す定数（"交換" = 0, "調整" = 1, "清掃" = 2）
  CORRECTIVE_ACTION_VALUES = {"EXCHANGE" => 0, "ADJUSTMENT" => 1, "CLEANING" => 2}
  # 点検結果を表すシンボル
  JUDGMENT_SYMBOLS = {true => "○", false => "×", nil => ""}

  validates_length_of :abnormal_content, :maximum => 140, :allow_nil => true

  def validate
    case self.check.entry_type
    when Check::ENTRY_TYPES["NORMAL_OR_ABNORMAL"]
      if self.judgment.nil?
        errors.add :judgment, :not_selected
      else
        unless self.judgment || !self.abnormal_content.blank?
          errors.add :abnormal_content, :blank
        else
          self.abnormal_content, self.corrective_action = nil, nil if self.judgment
        end
      end
    when Check::ENTRY_TYPES["MEASURED_VALUE"]
      unless self.measured_value
        errors.add :measured_value, :blank
      else
        # "点検結果(測定値)"の文字列表現が不正の場合
        unless self.measured_value_before_type_cast.to_s =~ /^[\-]?[0-9]{1,4}$|^[\-]?[0-9]{1,4}\.[0-9]{1,4}$/
          errors.add :measured_value, :not_a_number
          # 検証を中断する
          return
        end
        # "点検結果(測定値)"が"異常"で、"異常内容"が未入力の場合
        unless self.judgment || !self.abnormal_content.blank?
          errors.add :abnormal_content, :blank
        else
          self.abnormal_content, self.corrective_action = nil, nil if self.judgment
        end
      end
    end
  end

  # 点検種別に応じて点検結果の正常/異常を判断する。
  #
  # ＜点検種別が正常/異常を選択する場合＞
  # ・点検結果テーブルの点検結果から判断する。
  # ＜点検種別が測定値を入力する場合＞
  # ・点検内容テーブルの基準値と点検結果テーブルの測定値を比較し点検結果を判断する。
  # === 引き数
  # なし
  # === 戻り値
  # *true* 点検結果が正常の場合 / *false* 点検結果が異常の場合
  def judgment
    case self.check.entry_type
    when Check::ENTRY_TYPES["NORMAL_OR_ABNORMAL"]
      return super
    when Check::ENTRY_TYPES["MEASURED_VALUE"]
      if self.measured_value
        return self.check.lower_limit <= self.measured_value && self.check.upper_limit >= self.measured_value unless self.check.lower_limit.blank? || self.check.upper_limit.blank?
        return self.check.lower_limit <= self.measured_value unless self.check.lower_limit.blank?
        return self.check.upper_limit >= self.measured_value unless self.check.upper_limit.blank?
      else
        return super
      end
    end
  end

  # 対応日時の保存状態に応じて対応者氏名コードを更新する。
  #
  # ＜対応日時が保存済みの場合＞
  # ・点検者氏名コードの値で対応者氏名コードを更新する。
  # ＜対応日時が保存されていない場合＞
  # ・何も処理をしない。
  # === 引き数
  # なし
  # === 戻り値
  # *true* 対応者氏名コードを正常に更新できた場合
  # *ActiveRecord::RecordInvalid* 対応者氏名コードを正常に更新できなかった場合
  # *nil* 対応日時が保存されていない場合
  def set_staff_code!
    self.update_attributes!(:staff_code => self.check.inspection.staff_code) if self.corrected_datetime
  end

  # 点検結果に値をセットし保存する。
  #
  # ＜validationして保存する場合＞
  # ・点検日時を更新する
  # ・結果が異常かつ対応・処置が選択されているときは、対応日時を更新する
  # ・上記以外の場合は、対応日時をブランクにする
  # ＜validationせずに保存する場合＞
  # ・値はそのままにする
  def save_with_validation(with_validation)
    if with_validation
      update_datetime = DateTime.now
      self.attributes = {:checked_datetime => update_datetime}
      unless self.judgment or self.corrective_action.nil?
        self.attributes = {:corrected_datetime => update_datetime}
      else
        self.attributes = {:corrected_datetime => nil}
      end
    end
    super
  end

  # 対応情報を更新する。
  #
  # === 引き数
  # 対応情報を含むハッシュ
  # === 戻り値
  # *true* 更新に成功した場合
  # *false* 更新に失敗した場合
  # 失敗した場合は、.errors.full_messagesでエラーメッセージを取得できます。
  def update_correction(attr)
    attr.each_key do |key|
      case key.to_sym
      when :abnormal_content, :staff_code, :corrected_datetime, :corrective_content
        errors.add key, I18n.t("activerecord.errors.messages.blank") if attr[key].blank?
      end
    end
    errors.add :corrective_action, I18n.t("activerecord.errors.messages.not_selected") unless attr.has_key?(:corrective_action)
    errors.add :abnormal_content, I18n.t("activerecord.errors.messages.too_long", :count => 140) if attr[:abnormal_content].mb_chars.size > 140
    errors.add :corrective_content, I18n.t("activerecord.errors.messages.too_long", :count => 140) if attr[:corrective_content].mb_chars.size > 140
    errors.add :staff_code, I18n.t("activerecord.errors.messages.wrong_length_with_half_width_char_and_num", :count => 7) unless attr[:staff_code] =~ /\A[a-zA-Z0-9]{7}\Z/
    unless attr[:corrected_datetime] =~ /\A\d{4}\/\d{1,2}\/\d{1,2} \d{1,2}:\d{1,2}:\d{1,2}\z/
      errors.add_to_base I18n.t("activerecord.errors.models.result.corrected_date_format_was_invalid") 
    else
      errors.add_to_base I18n.t("activerecord.errors.models.result.corrected_date_format_was_invalid") if ((Time.parse(attr[:corrected_datetime]) rescue ArgumentError) == ArgumentError)
    end
    return false  if self.errors.size > 0

    self.update_attributes(attr)
  end
end
