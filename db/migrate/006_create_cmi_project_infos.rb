class CreateCmiProjectInfos < ActiveRecord::Migration
  def self.up
    create_table :cmi_project_infos do |t|
      t.integer :project_id, :null => false
      t.decimal :total_income, :precision => 12, :scale => 2, :null => false
      t.date :actual_start_date, :null => false
      t.date :scheduled_start_date, :null => false
      t.date :scheduled_finish_date, :null => false
      t.integer :scheduled_qa_meetings, :null => false
      t.text :scheduled_role_effort
      t.timestamps
    end

    add_index :cmi_project_infos, :project_id, :unique => true
  end

  def self.down
    drop_table :cmi_project_infos
  end
end
