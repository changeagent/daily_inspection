# Inspectionsテーブルのモデル。
class Inspection < ActiveRecord::Base
  has_many :checks

  validates_presence_of :staff_code, :on => :update
  validates_format_of :staff_code, :with => /\A[a-zA-Z0-9]{7}\Z/, :on => :update, :allow_blank => true, 
                      :message => I18n.t("activerecord.errors.messages.wrong_length_with_half_width_char_and_num", :count => 7)

  # 点検結果の内容を検証する。
  # ・点検結果テーブルにレコードが存在するか。
  # ・点検結果レコードは妥当なデータか（Resultモデルの検証が通るデータか）。
  # === 引き数
  # なし
  # === 戻り値
  # *true* 検証に成功した場合 / *false* 検証に失敗した場合
  def validate
    unless self.id.blank?
      Check.find(:all, :include => [:result],
        :conditions => ['inspection_id = ?', self.id],
        :order => 'checks.sequence').each_with_index do |check, index|
        if check.result
          errors.add "#{index + 1}", :check_result_was_invalid unless check.result.valid?
        else
          errors.add "#{index + 1}", :has_not_been_checked
        end
      end
    end
  end

  # 点検を最終的に保存する。
  # ・点検者氏名コードを更新する。
  # ・点検結果の対応者氏名コードを更新する。
  # ・点検内容（マスタ）の点検予定日を更新する。
  # === 引き数
  # *inspection*:: 点検を格納する配列（Inspectionsテーブルのカラムを有するハッシュを指定すること）
  # === 戻り値
  # *true* 保存に成功した場合 / *false* 保存に失敗した場合
  def finish(inspection)
    self.transaction do
      self.update_attributes!(inspection)
      begin
        self.checks.each do |check|
          check.result.set_staff_code!
          check.update_master_schedule!
        end
      rescue => e
        self.errors.add_to_base e.message
        raise e
      end
    end
    return true
  rescue
    return false
  end
  
end
