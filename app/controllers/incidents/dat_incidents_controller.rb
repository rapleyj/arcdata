class Incidents::DatIncidentsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json
  #load_and_authorize_resource :incident, find_by: :find_by_incident_number!
  load_and_authorize_resource :dat_incident, class: Incidents::DatIncident
  defaults singleton: true
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident

  actions :all, except: [:destroy]

  prepend_before_filter :redirect_from_existing_incident, only: :new

  def redirect_from_existing_incident
    if parent.dat_incident and !parent.dat_incident.new_record?
      redirect_to action: :edit and return
    end
  end

  def new
    build_resource

    begin
      idat_db = current_chapter.idat_database
      if idat_db.present?
        importer = Idat::IncidentImporter.new(idat_db)
        importer.get_incident(params[:incident_id], resource)
      end
    rescue => e
      Raven.capture e
    end

    new!
  end

  def edit
    unless parent? and parent.dat_incident
      #redirect_to action: :new and return
      build_resource
    end
    if params[:status]
      resource.incident.status = params[:status]
      resource.valid?
    end
    if params[:panel_name]
      render action: 'panel', layout: nil
    else
      edit!
    end
  end

  def update
    action = params[:action] == 'create' ? :create! : :update!
    self.send(action) do |success, failure|
      success.html {notify(true); redirect_to resource.incident}
      success.js { notify(true); render action: 'update' }
      failure.js { render action: 'panel', layout: nil}
    end
  end
  alias_method :create, :update

  private
  def notify(is_new=true)
    Incidents::IncidentReportFiled.new(resource.incident.reload, is_new).save
  end

  helper_method :form_url
  def form_url
    params[:incident_id] ? incidents_incident_dat_path(params[:incident_id]) : incidents_dat_incidents_path
  end

  helper_method :grouped_responder_roles
  def grouped_responder_roles
    @_roles ||= [["Did Not Respond", Incidents::ResponderAssignment::RESPONSES_TO_LABELS.invert.to_a],
     ["Responded To Incident", Incidents::ResponderAssignment::ROLES_TO_LABELS.invert.to_a.reject{|a| a.last == 'team_lead'}]]
  end

  helper_method :scheduled_responders, :flex_responders
  def scheduled_responders(obj=@dat_incident)
    if obj.incident.area
      time = obj.incident.created_at || current_chapter.time_zone.now
      groups = Scheduler::ShiftGroup.current_groups_for_chapter(current_chapter, time)
      assignments = Scheduler::ShiftAssignment.joins{[shift]}.includes{[shift, person]}.where{(shift.county_id == my{obj.incident.area})}.for_active_groups(groups)
                    .select{|ass| !obj.incident.responder_assignments.detect{|resp| resp.person == ass.person }}
    else
      []
    end
  end

  def flex_responders(obj=@dat_incident, scheduled_responders)
    if obj.incident.area
      time = obj.incident.created_at.in_time_zone(current_chapter.time_zone) || current_chapter.time_zone.now
      dow = time.strftime("%A").downcase
      hour = time.hour
      period = (hour >= 7 && hour < 19) ? 'day' : 'night'
      schedules = Scheduler::FlexSchedule.for_county(obj.incident.area).available_at(dow, period).includes{person}
      assignments = schedules.select{|sched| !obj.incident.responder_assignments.detect{|resp| resp.person == sched.person }}
                    .select{|sched| !scheduled_responders.detect{|resp| resp.person == sched.person }}
    else
      []
    end
  end

  def prepare_resource(obj)
    inc_attrs = incident_params
    obj.incident.attributes = inc_attrs if inc_attrs

    return unless %w(new edit).include? params[:action] 

    obj.build_incident if obj.incident.nil?
    obj.incident.build_evac_partner_use if obj.incident.evac_partner_use.nil?
    obj.incident.build_feeding_partner_use if obj.incident.feeding_partner_use.nil?
    obj.incident.build_hotel_partner_use if obj.incident.hotel_partner_use.nil?
    obj.incident.build_shelter_partner_use if obj.incident.shelter_partner_use.nil?

    obj.incident.build_team_lead role: 'team_lead', response: 'available' unless obj.incident.team_lead
  end

  def build_resource
    return @dat_incident if @dat_incident

    obj = super

    obj.completed_by ||= current_user
    prepare_resource(obj)    

    @dat_incident = obj
  end

  def resource
    @dat_incident ||= super.tap{|obj| prepare_resource(obj) }
  end

  def end_of_association_chain
    Incidents::Incident.includes{[dat_incident.completed_by, dat_incident.vehicles, responder_assignments.person]}.where{(chapter_id == my{current_chapter}) & (incident_number == my{params[:incident_id]})}.first!
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      return [] if request.get?

      keys = [:incident_call_type, :team_lead_id,
             :num_adults, :num_children, :num_families, :num_cases, 
             :incident_type, :incident_description, :narrative_brief, :narrative,
             :num_people_injured, :num_people_hospitalized, :num_people_deceased,
             :responder_notified, :responder_arrived, :responder_departed,
             :units_affected, :units_minor, :units_major, :units_destroyed,
             :structure_type,
             {vehicle_ids: []},
             {languages: []},
             {services: []}
           ]

      keys = keys + Incidents::DatIncident::TRACKED_RESOURCE_TYPES.map(&:to_sym)

      args = params.require(:incidents_dat_incident).permit(*keys)
      if args[:vehicle_ids]
        args[:vehicle_ids] = Array(args[:vehicle_ids]).select(&:present?).uniq
      end

      [args]
    end

    def incident_params
      return nil if request.get?
      return @_incident_params if defined?(@_incident_params)

      partner_use_params = [:partner_id, :partner_name, :hotel_rate, :hotel_rooms, :meals_served]

      base = params.require(:incidents_dat_incident)[:incident_attributes]
      if base
        @_incident_params ||= base.permit([
          :incident_type, :narrative, :status,
          :address, :city, :state, :zip, :lat, :lng, :county, :neighborhood,
          {:team_lead_attributes => [:id, :person_id, :role, :response]},
          {:responder_assignments_attributes => [:id, :person_id, :role, :response, :_destroy, :was_flex]},
          :evac_partner_used,
          {:evac_partner_use_attributes => partner_use_params},
          :feeding_partner_used,
          {:feeding_partner_use_attributes => partner_use_params},
          :shelter_partner_used,
          {:shelter_partner_use_attributes => partner_use_params},
          :hotel_partner_used,
          {:hotel_partner_use_attributes => partner_use_params}
        ])
      else
        {}
      end
    end
end
