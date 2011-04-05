class CreateChecks < ActiveRecord::Migration
  def self.up
    create_table :checks do |t|
      t.integer :inspection_id
      t.integer :part_id
      t.string :item
      t.string :operation
      t.string :criterion
      t.integer :type
      t.bigdecimal :upper_limit
      t.bigdecimal :lower_limit
      t.string :unit_name
      t.integer :order

      t.timestamps
    end
  end

  def self.down
    drop_table :checks
  end
end
