Feature: オペレータとしてマイナス値を入力したい

  # ＜点検入力画面＞
  # 画面全体
  # ・画面の表示領域は携帯端末のサイズ（1024*600）
  # ・画面サイズ内に収めて表示する
  # 画面構成
  # ・「前へ」ボタン:
  #   ・画面上部分左へ配置する
  # ・「次へ」ボタン:
  #   ・画面上部分右へ配置する
  # ・部位:
  #   ・画面上部分中央へ表示する
  #   ・上限30文字
  #   ・漢字、ひらがな以外(英数字、カタカナ)は半角
  # ・項目:
  #   ・上限40文字
  #   ・1行で表示する
  # ・方法:
  #   ・上限80文字
  #   ・2行で表示する
  # ・基準:
  #   ・上限80文字
  #   ・2行で表示する
  #   ・下限値または上限値がある場合は文末に単位を付けて表示する
  # ・点検結果:
  #   ・正常／異常選択式または数値入力式の2通り
  #   ・正常／異常選択式
  #     ・ラジオボタンで「正常」、「異常」を選択する
  #     ・選択解除ができる
  #   ・数値入力式
  #     ・テキストフィールドに数値を入力する
  #     ・数値は整数部4桁、小数部4桁まで入力可能
  #     ・テキストフィールド欄横に単位を表示する
  # ・異常内容:
  #   ・テキストフィールドに入力する
  #   ・上限140文字
  # ・対応・処置:
  #   ・ラジオボタンで「交換」、「調整」、「清掃」を選択する
  #   ・選択解除ができる

  #01
  Scenario: 基準の上限値・下限値にマイナス値を表示でき、点検結果にマイナス値を入力し保存できる
    Given 以下の点検内容を含む点検を開始している:
      |部位名 |項目  |方法  |基準  |下限値     |上限値  |単位  |点検順  |
      |部位W  |項目A |方法A |基準A |           |-0.0001 |L/min |0       |
      |部位X  |項目A |方法A |基準A |-9000.0005 |        |L/min |1       |
      |部位V  |項目A |方法A |基準A |-100       |-50     |L/min |2       |

    When "1"番目の点検内容を"点検入力"画面に表示する

    Then 以下の点検内容を表示していること:
      |部位  |項目  |方法  |基準内容 |基準範囲         |点検結果 |異常内容 |対応・処置 |
      |部位W |項目A |方法A |基準A    |～ -0.0001 L/min |(空白)   |(空白)   |(未選択)   |

      # ※ 前提データの点検順が0のデータが1番目のデータとして表示される

    When "点検結果"に"-0.0003"を入力する
    And "次へ"ボタンをクリックする

    Then 以下の点検内容を表示していること:
      |部位  |項目  |方法  |基準  |基準範囲            |点検結果 |異常内容 |対応・処置 |
      |部位X |項目A |方法A |基準A |-9000.0005 L/min ～ |(空白)   |(空白)   |(未選択)   |

    When "点検結果"に"-9000.0006"を入力する
    And 前へボタンをクリックする

    Then 以下の点検内容を表示していること:
      |部位  |項目  |方法  |基準  |基準範囲         |点検結果 |異常内容 |対応・処置 |
      |部位W |項目A |方法A |基準A |～ -0.0001 L/min |-0.0003  |(空白)   |(未選択)   |

    When "次へ"ボタンをクリックする

    Then 以下の点検内容を表示していること:
      |部位  |項目  |方法  |基準  |基準範囲            |点検結果   |異常内容 |対応・処置 |
      |部位X |項目A |方法A |基準A |-9000.0005 L/min ～ |-9000.0006 |(空白)   |(未選択)   |

    When "点検結果"に"-9000.0004"を入力する
    And "次へ"ボタンをクリックする

    Then 以下の点検内容を表示していること:
      |部位  |項目  |方法  |基準  |基準範囲              |点検結果 |異常内容 |対応・処置 |
      |部位V |項目A |方法A |基準A |-100.0 ～ -50.0 L/min |(空白)   |(空白)   |(未選択)   |

    When "点検結果"に"-49.9999"を入力する
    And "次へ"ボタンをクリックする

    Then "異常内容を入力してください"とアラートメッセージが表示されること