class AddUpperLimitToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :upper_limit, :decimal, :precision => 4, :scale => 2
    add_column :checks, :lower_limit, :decimal, :precision => 4, :scale => 2
  end

  def self.down
    remove_column :checks, :lower_limit
    remove_column :checks, :upper_limit
  end
end
