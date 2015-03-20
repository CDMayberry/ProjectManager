class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.string :company
      t.date :start_date
      t.date :end_date
      t.text :description
      
      t.timestamps
    end
  end
end
