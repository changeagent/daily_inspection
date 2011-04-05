class AddEquipmentToParts < ActiveRecord::Migration
  def self.up
    add_column :parts, :equipment_id, :integer
  end

  def self.down
    remove_column :parts, :equipment_id
  end
end
