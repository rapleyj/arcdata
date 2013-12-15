class Incidents::Attachment < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: :attachments
  belongs_to :person, class_name: 'Roster::Person'

	assignable_values_for :attachment_type, allow_blank: true do
		%w(document, scene_photo, damage_assessment_photo)
	end
end
