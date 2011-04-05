class CreateCycles < ActiveRecord::Migration
  def self.up
    create_table :cycles do |t|
      t.string :title
      t.integer :unit_type
      t.integer :interval

      t.timestamps
    end
  end

  def self.down
    drop_table :cycles
  end
end
