ActiveAdmin.register Incidents::NotificationSubscription, as: 'Notification' do
  menu parent: 'Incidents'

  filter :notification_type

  controller do
    def collection
      @_collection ||= super.includes{person}
    end

    def resource_params
      request.get? ? [] : [params.require(:notification).permit(:person_id, :county_id, :notification_type)]
    end
  end

  index do
    column :person
    column :notification_type
    column :county
    column :persistent
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :person
      f.input :county
      f.input :notification_type, collection: Incidents::NotificationSubscription::TYPES.map{|x| [x.titleize, x]}
      f.input :persistent
      f.actions
    end
  end
end
