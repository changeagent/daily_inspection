require File.join(File.dirname(__FILE__), 'seed_steps.rb')

# 以下のサイクルが登録されている
the_following_cycles_are_registered %{
  |周期 |間隔 |単位  |
  |S    |8    |時間  |
  |D    |24   |時間  |
  |W    |168  |時間  |
  |M    |1    |ヶ月  |
}

# 以下の工程と設備が登録されている
the_following_stations_and_equipment_are_registerd %{
  |工程名               |設備名    |
  |工程Ａ               |設備Ａ    |
  |工程Ｂ               |設備Ｂ    |
  |工程Ｂ               |設備Ｃ    |
  |工程Ｃ               |設備Ｄ    |
  |工程Ｃ               |設備Ｅ    |
}

# 以下の点検マスタが登録されている
the_following_check_masters_are_registered %{
  |工程名               |設備名    |周期 |部位名 |部位順 |項目   |項目順 |方法   |基準   |下限値     |上限値  |単位  |点検形式 |点検予定日(X日後) |点検予定時 |
  |工程Ａ               |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |方法Ａ |基準Ａ |           |        |      |選択式   |0                 |09:00:00   |
  |工程Ａ               |設備Ａ    |W    |部位S  |0      |項目Ｂ |1      |方法Ａ |基準Ａ |           |        |      |選択式   |0                 |09:00:00   |
  |工程Ａ               |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |方法Ａ |基準Ａ |           |        |      |選択式   |0                 |17:00:00   |
  |工程Ａ               |設備Ａ    |M    |部位T  |1      |項目Ｄ |0      |方法Ａ |基準Ａ |           |        |      |選択式   |0                 |13:00:00   |
  |工程Ａ               |設備Ａ    |M    |部位U  |2      |項目Ｄ |0      |方法Ａ |基準Ａ |           |        |      |選択式   |1                 |09:00:00   |
  |工程Ｃ               |設備Ｄ    |D    |部位W  |0      |項目Ｅ |0      |方法Ａ |基準Ｂ |           |-0.0001 |L/min |入力式   |0                 |00:00:00   |
  |工程Ｃ               |設備Ｄ    |D    |部位X  |1      |項目Ｅ |0      |方法Ａ |基準Ｂ |-9000.0005 |        |L/min |入力式   |0                 |00:00:00   |
  |工程Ｃ               |設備Ｄ    |D    |部位V  |2      |項目Ｅ |0      |方法Ａ |基準Ｂ |-100       |-50     |L/min |入力式   |0                 |00:00:00   |
  |工程Ｃ               |設備Ｅ    |D    |部位Y  |3      |項目Ａ |0      |方法Ａ |基準Ａ |           |        |      |選択式   |0                 |09:00:00   |
}

# 以下の点検が登録されている
the_following_checks_are_registered %{
  |工程名           |設備名    |周期 |部位名 |部位順 |項目   |項目順 |点検日(X日前) |点検時刻   |結果 |測定値    |異常内容 |対応・処置 |点検順 |点検ID |点検者氏名コード |点検完了時刻 |
  |工程Ａ           |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |7             |13:25:00   |○   |          |         |           |0      |1      |staff01          |13:30:00     |
  |工程Ａ           |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |6             |09:25:00   |○   |          |         |           |0      |3      |staff03          |09:30:00     |
  |工程Ａ           |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |5             |10:40:00   |×   |          |異常A    |交換       |0      |6      |staff06          |10:45:00     |
  |工程Ａ           |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |4             |13:25:00   |○   |          |         |           |0      |9      |staff09          |13:30:00     |
  |工程Ａ           |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |3             |15:25:00   |○   |          |         |           |0      |12     |staff12          |15:30:00     |
  |工程Ａ           |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |2             |11:15:00   |×   |          |異常B    |           |0      |15     |staff15          |11:20:00     |
  |工程Ａ           |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |1             |10:25:00   |○   |          |         |           |0      |18     |staff18          |10:30:00     |
  |工程Ａ           |設備Ａ    |D    |部位S  |0      |項目Ａ |0      |0             |09:25:00   |○   |          |         |           |0      |21     |staff21          |09:30:00     |
  |工程Ａ           |設備Ａ    |W    |部位S  |0      |項目Ｂ |1      |3             |15:26:00   |○   |          |         |           |1      |12     |staff12          |15:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |6             |03:25:00   |○   |          |         |           |0      |2      |staff02          |03:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |6             |09:26:00   |○   |          |         |           |1      |3      |staff03          |09:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |6             |20:25:00   |○   |          |         |           |0      |4      |staff04          |20:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |5             |01:25:00   |○   |          |         |           |0      |5      |staff05          |01:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |5             |10:41:00   |×   |          |異常C    |           |1      |6      |staff06          |10:45:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |5             |22:10:00   |○   |          |         |           |0      |7      |staff07          |22:15:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |4             |04:40:00   |○   |          |         |           |0      |8      |staff08          |04:45:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |4             |13:26:00   |○   |          |         |           |1      |9      |staff09          |13:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |4             |21:25:00   |○   |          |         |           |0      |10     |staff10          |21:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |3             |05:25:00   |○   |          |         |           |0      |11     |staff11          |05:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |3             |15:27:00   |○   |          |         |           |2      |12     |staff12          |15:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |2             |00:05:00   |×   |          |異常D    |           |0      |13     |staff13          |00:10:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |2             |03:25:00   |○   |          |         |           |0      |14     |staff14          |03:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |2             |11:16:00   |○   |          |         |           |1      |15     |staff15          |11:20:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |2             |18:35:00   |○   |          |         |           |0      |16     |staff16          |18:40:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |1             |06:25:00   |○   |          |         |           |0      |17     |staff17          |06:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |1             |10:26:00   |○   |          |         |           |1      |18     |staff18          |10:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |1             |23:25:00   |○   |          |         |           |0      |19     |staff19          |23:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |0             |03:25:00   |○   |          |         |           |0      |20     |staff20          |03:30:00     |
  |工程Ａ           |設備Ａ    |S    |部位S  |0      |項目Ｃ |2      |0             |09:26:00   |○   |          |         |           |0      |21     |staff21          |09:30:00     |
  |工程Ａ           |設備Ａ    |M    |部位T  |1      |項目Ｄ |0      |5             |22:11:00   |○   |          |         |           |1      |7      |staff07          |22:15:00     |
  |工程Ａ           |設備Ａ    |M    |部位U  |2      |項目Ｄ |0      |              |           |     |          |         |           |       |       |                 |             |
  |工程Ｂ           |設備Ｂ    |     |       |       |       |       |              |           |     |          |         |           |       |       |                 |             |
  |工程Ｂ           |設備Ｃ    |     |部位V  |0      |       |       |              |           |     |          |         |           |       |       |                 |             |
  |工程Ｃ           |設備Ｄ    |D    |部位W  |0      |項目Ｅ |0      |0             |03:25:00   |     |-0.0001   |         |           |0      |22     |staff22          |03:30:00     |
  |工程Ｃ           |設備Ｄ    |D    |部位X  |1      |項目Ｅ |0      |0             |03:30:00   |     |-9000.0006|異常E    |交換       |1      |22     |staff22          |03:30:00     |
  |工程Ｃ           |設備Ｄ    |D    |部位V  |2      |項目Ｅ |0      |0             |03:35:00   |     |-49       |異常F    |           |2      |22     |staff22          |03:30:00     |
  |工程Ｃ           |設備Ｅ    |D    |部位Y  |3      |項目Ａ |0      |0             |03:35:00   |○   |          |         |           |0      |23     |staff23          |10:40:00    |
}

# 以下の対応・処置、対応内容が点検後に登録されている
the_following_corrections_are_registered %{
  |点検ID |点検順 |対応・処置 |対応内容            |点検後 対応者氏名コード |備考                      |
  |15     |0      |調整       |部位Sを調整しました |staff90                 |正常/異常を選択する点検   |
  |22     |2      |交換       |部位Vを交換しました |staff90                 |測定値を入力する点検      |
}

# 以下の最大長データが登録されている
# MEMO:最大長データのデモが不要な場合は、削除してください。
the_following_maxlength_data_are_registered %{
  |件数 |工程名    |最長 |設備名  |最長|周期 |部位名 |最長|項目 |最長|方法 |最長|基準 |最長|点検終了日(X日前)|点検予定日(X日後)  |点検予定時(X時間後)|
  |20   |工        |10   |S       |5   |D    |部     |30  |項   |40  |方   |80  |基   |80  |1                |0                  |-1                 |
}