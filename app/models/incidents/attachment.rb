class Incidents::Attachment < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: :attachments
  belongs_to :person, class_name: 'Roster::Person'

  validates :name, :incident, presence: { allow_blank: false }
  validates :person, presence: { allow_blank: false }

	ATTACHMENT_TYPES = {
    "Document" => 'document',
    "Scene Photo" => 'scene_photo',
    "Damage Assessment Photo" => 'damage_assessment_photo',
  }

  assignable_values_for :attachment_type do
    ATTACHMENT_TYPES.invert
  end
end
