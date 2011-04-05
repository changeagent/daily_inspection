class RenameColumnOrder < ActiveRecord::Migration
  def self.up
    rename_column :checks, :order, :sequence
    rename_column :parts, :order, :sequence
  end

  def self.down
    rename_column :checks, :sequence, :order
    rename_column :parts, :sequence, :order
  end
end
