class DropProcess < ActiveRecord::Migration
  def self.up
    drop_table :processes
  end

  def self.down
    create_table :processes do |t|
      t.string :name
      t.timestamps
    end
  end
end
