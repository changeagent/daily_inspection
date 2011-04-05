# 日常点検システムの画面で使用する共通ヘルパーモジュール。
module ApplicationHelper

  # ラジオボタンの選択を解除するJavaScriptを取得する。
  # === 引き数
  # *form_id*:: 選択を解除するラジオボタンが配置されたフォームID
  # *element_id*:: 選択を解除するラジオボタンの要素ID
  # === 戻り値
  # ラジオボタンの選択を解除するJavaScript
  def uncheck_radio_button_js(form_id, element_id)
    "javascript:radio_button=document.forms['#{form_id}'].#{element_id};if(radio_button.checked==true){radio_button.checked=false;}else{radio_button.checked=true;}"
  end

  # 日時を指定されたフォーマットに整形する
  # === 引き数
  # *time*:: 変換する時刻オブジェクト
  #          ※時刻オブジェクト以外の場合のエラー処理は行っていない
  # === 戻り値
  # 日時を表す文字列に変換した結果
  def format_datetime(time)
    time.strftime("%Y/%m/%d %H:%M:%S") unless time.nil?
  end
end
