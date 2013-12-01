class Incidents::Attachment < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'

  assignable_values_for :structure_type, allow_blank: true do
    %w(document, scene_photo, damage_assessment_photo)
  end
end
