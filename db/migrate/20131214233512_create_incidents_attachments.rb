class CreateIncidentsAttachments < ActiveRecord::Migration
  def change
    create_table :incidents_attachments do |t|
      t.references :incident, index: true
      t.references :person, index: true
      t.string :name
      t.string :description
      t.string :attachment_type

      t.timestamps
    end
  end
end
