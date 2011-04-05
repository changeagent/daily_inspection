class ChangeColumnChecksUpperLimitsAndLowerLimits < ActiveRecord::Migration
  def self.up
    change_column :checks, :upper_limit, :decimal, :precision => 8, :scale => 4
    change_column :checks, :lower_limit, :decimal, :precision => 8, :scale => 4
  end

  def self.down
    change_column :checks, :upper_limit, :decimal, :precision => 4, :scale => 2
    change_column :checks, :lower_limit, :decimal, :precision => 4, :scale => 2
  end
end
