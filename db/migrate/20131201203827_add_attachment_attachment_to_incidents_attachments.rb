class AddAttachmentAttachmentToIncidentsAttachments < ActiveRecord::Migration
  def self.up
    change_table :incidents_attachments do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :incidents_attachments, :attachment
  end
end
