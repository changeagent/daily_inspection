class ChangeColumnChecksScheduledDatetime < ActiveRecord::Migration
  def self.up
    change_column :checks, :scheduled_datetime, :datetime, :null => false
  end

  def self.down
    change_column :checks, :scheduled_datetime, :datetime
  end
end
