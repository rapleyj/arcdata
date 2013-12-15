class Incidents::AttachmentsController < Incidents::EditPanelController
	self.panel_name = 'photos'

  protected

  def build_resource
    #super.tap{|log| log.event_time ||= Time.current }
  end

  def resource_params
    request.get? ? [] : [params.require(:incidents_attachment).permit(:attachment_type, :name, :description).merge(person_id: current_user.id)]
  end
end
