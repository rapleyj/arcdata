class Incidents::Attachment < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: :attachments
  belongs_to :person, class_name: 'Roster::Person'
end
