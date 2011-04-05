class ChangeColumnChecksItemAndOperationAndCriterion < ActiveRecord::Migration
  def self.up
    change_column :checks, :item, :string, :limit => 40
    change_column :checks, :operation, :string, :limit => 80
    change_column :checks, :criterion, :string, :limit => 80
  end

  def self.down
    change_column :checks, :item, :string
    change_column :checks, :operation, :string
    change_column :checks, :criterion, :string
  end
end
