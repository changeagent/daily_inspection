class RenameColumnType < ActiveRecord::Migration
  def self.up
    rename_column :checks, :type, :entry_type
  end

  def self.down
    rename_column :checks, :entry_type, :type
  end
end
