class AddCheckedDatetimeCorrectiveContentStaffCodeCorrectedDatetimeToResults < ActiveRecord::Migration
  def self.up
    add_column :results, :checked_datetime, :datetime
    add_column :results, :corrective_content, :string
    add_column :results, :staff_code, :string
    add_column :results, :corrected_datetime, :datetime
  end

  def self.down
    remove_column :results, :checked_datetime
    remove_column :results, :corrective_content
    remove_column :results, :staff_code
    remove_column :results, :corrected_datetime
  end
end
