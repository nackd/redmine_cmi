class CreateCmiExpenditures < ActiveRecord::Migration
  def self.up
    create_table :cmi_expenditures do |t|
      t.integer :project_id, :null => false
      t.integer :author_id, :null => false
      t.string :concept, :null => false
      t.text :description
      t.integer :initial_budget, :null => false
      t.integer :current_budget, :null => false
      t.integer :incurred, :null => false, :default => 0
      t.timestamps
    end

    add_index :cmi_expenditures, :project_id
  end

  def self.down
    drop_table :cmi_expenditures
  end
end
