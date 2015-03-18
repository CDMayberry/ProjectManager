class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.belongs_to :projects, index: true
      t.belongs_to :employees, index: true
      t.timestamps null: false
    end
  end
end
