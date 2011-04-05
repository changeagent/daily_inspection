# 日常点検システムの設備に関する画面で使用するヘルパーモジュール。
module EquipmentHelper

  # 点検結果に応じて表示する文字列、リンクを生成する。
  # === 引き数
  # *check_id*:: 点検内容ID
  # *judgment*:: 点検結果
  #   ・正常の場合：true
  #   ・異常の場合：false
  #   ・無い場合：nil
  # === 戻り値
  # 点検結果（但し、点検内容IDが nil の場合、戻り値は nil となる）
  #   ・正常の場合："○"
  #   ・異常の場合："×" および 異常対応確認入力画面へのリンク
  #   ・無い場合：""（未入力）
  def link_corrections_show(check_id, judgment)
    return check_id if check_id.nil?
    return Result::JUDGMENT_SYMBOLS[judgment] if judgment || judgment.nil?
    return link_to Result::JUDGMENT_SYMBOLS[judgment], {:controller => 'corrections', :action => 'show', :id => check_id}
  end
  
end
