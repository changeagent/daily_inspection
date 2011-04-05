class AddProcessToEquipment < ActiveRecord::Migration
  def self.up
    add_column :equipment, :process_id, :integer
  end

  def self.down
    remove_column :equipment, :process_id
  end
end
