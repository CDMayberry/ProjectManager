class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.references :user, index: true
      t.references :project, index: true

      t.timestamps
    end
  end
end
