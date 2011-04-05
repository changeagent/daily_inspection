class AddStationToEquipment < ActiveRecord::Migration
  def self.up
    add_column :equipment, :station_id, :integer
    remove_column :equipment, :process_id
  end

  def self.down
    remove_column :equipment, :station_id
    add_column :equipment, :process_id, :integer
  end
end
