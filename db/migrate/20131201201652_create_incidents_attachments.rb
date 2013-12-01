class CreateIncidentsAttachments < ActiveRecord::Migration
  def change
    create_table :incidents_attachments do |t|
      t.string :name
      t.string :description
      t.string :attachment_type

      t.timestamps
    end
  end
end
