class CreateCmiCheckpoints < ActiveRecord::Migration
  def self.up
    create_table :cmi_checkpoints do |t|
      t.integer :project_id, :null => false
      t.integer :author_id, :null => false
      t.text :description
      t.date :checkpoint_date, :null => false
      t.date :scheduled_finish_date, :null => false
      t.integer :scheduled_qa_meetings, :null => false
      t.text :scheduled_role_effort
      t.timestamps
    end

    add_index :cmi_checkpoints, :project_id
  end

  def self.down
    drop_table :cmi_checkpoints
  end
end
