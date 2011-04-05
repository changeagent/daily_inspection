class AddPartNameToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :part_name, :string
  end

  def self.down
    remove_column :checks, :part_name
  end
end
