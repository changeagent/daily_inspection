class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|
      t.references :check
      t.boolean :judgment  # 点検結果
      t.decimal :measured_value, :precision => 8, :scale => 4  # 点検結果（数値）
      t.string :abnormal_content  # 異常内容
      t.integer :corrective_action  # 対応・処置
      t.timestamps
    end
  end

  def self.down
    drop_table :results
  end
end
