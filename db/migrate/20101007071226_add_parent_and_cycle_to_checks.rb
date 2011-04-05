class AddParentAndCycleToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :parent_id, :integer
    add_column :checks, :cycle_id, :integer
    add_column :checks, :cycle_title, :string
    add_column :checks, :scheduled_datetime, :datetime
  end

  def self.down
    remove_column :checks, :parent_id
    remove_column :checks, :cycle_id
    remove_column :checks, :cycle_title
    remove_column :checks, :scheduled_datetime
  end
end
