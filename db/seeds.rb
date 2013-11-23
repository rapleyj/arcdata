# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Roster::CellCarrier.create name: 'Verizon', sms_gateway: '@vtext.com'

arcba = Roster::Chapter.create name:'American Red Cross Bay Area', short_name:'ARCBA', code: '05503', time_zone_raw: 'America/Los_Angeles'

all = arcba.counties.create name: 'Chapter', abbrev: 'CH'
sf = arcba.counties.create name: 'San Francisco', vc_regex_raw: 'San Francisco', abbrev: 'SF'
al = arcba.counties.create name: 'Alameda', vc_regex_raw: 'Alameda', abbrev: 'AL'
sm = arcba.counties.create name: 'San Mateo', vc_regex_raw: 'San Mateo', abbrev: 'SM'
so = arcba.counties.create name: 'Solano', vc_regex_raw: 'Solano', abbrev: 'SO'
mr = arcba.counties.create name: 'Marin', vc_regex_raw: 'Marin', abbrev: 'MR'
cc = arcba.counties.create name: 'Contra Costa', vc_regex_raw: 'Contra Costa', abbrev: 'CC'

arcba.positions.create name: 'Chapter Configuration', hidden: true
arcba.positions.create name: 'Chapter DAT Admin', hidden: true
[sf, al, sm, so, mr, cc].each do |county|
  arcba.positions.create name: "DAT Administrator - #{county.name}", vc_regex_raw: "#{county.name}.*DAT Administrator$"
  arcba.positions.create name: "Disaster Manager - #{county.name}", vc_regex_raw: "#{county.name}.*Disaster Manager$"
end

tl = arcba.positions.create name: 'DAT Team Lead', vc_regex_raw: 'Team Lead$'
tech = arcba.positions.create name: 'DAT Technician', vc_regex_raw: 'Technician$'
trainee = arcba.positions.create name: 'DAT Trainee', vc_regex_raw: 'Trainee$'
disp = arcba.positions.create name: 'DAT Dispatcher', vc_regex_raw: 'Dispatch$'
arcba.positions.create name: 'ERV Driver', vc_regex_raw: '^ERV$'
arcba.positions.create name: 'Bay Responder Driver', vc_regex_raw: '^Bay Responder$'
arcba.positions.create name: 'Forklift', vc_regex_raw: '^Forklift'
arcba.positions.create name: 'Tow Shelter Trailer', vc_regex_raw: '^Tow Shelter Trailer$'
arcba.positions.create name: 'Chapter Vehicle', vc_regex_raw: '^Chapter Vehicle'
arcba.positions.create name: 'CAC Activator', vc_regex_raw: '^CAC Activator'
arcba.positions.create name: 'DSHR', vc_regex_raw: 'DSHR'

day = Scheduler::ShiftGroup.create chapter: arcba, name: 'Day', start_offset: 25200, end_offset: 68400, period: 'daily'
night = Scheduler::ShiftGroup.create chapter: arcba, name: 'Night', start_offset: 68400, end_offset: 111600, period: 'daily'
week = Scheduler::ShiftGroup.create chapter: arcba, name: 'Weekly', start_offset: 0, end_offset: 7.days, period: 'weekly'
month = Scheduler::ShiftGroup.create chapter: arcba, name: 'Monthly', start_offset: 0, end_offset: 31, period: 'monthly'

[day, night].each do |group|
  [sf, al, sm, so, mr, cc].each do |county|
    Scheduler::Shift.create county: county, name: 'Team Lead', abbrev: 'TL', positions: [tl], shift_group: group, ordinal: 1, max_signups: 1, spreadsheet_ordinal: 1, dispatch_role: 1
    Scheduler::Shift.create county: county, name: 'Backup Lead', abbrev: 'BTL', positions: [tl], shift_group: group, ordinal: 2, max_signups: 1, spreadsheet_ordinal: 2, dispatch_role: 2
    if county == sf
      Scheduler::Shift.create county: county, name: 'Dispatch', abbrev: 'Disp', positions: [disp], shift_group: group, ordinal: 5, max_signups: 1, spreadsheet_ordinal: 3
    end
  end
end

Scheduler::Shift.create county: sf, name: 'Mental Health', abbrev: 'DMH', positions: [tl], shift_group: week, ordinal: 5, max_signups: 1
Scheduler::Shift.create county: sf, name: 'Health Services', abbrev: 'DHS', positions: [tl], shift_group: month, ordinal: 6, max_signups: 1
  



chicago_chapter = Roster::Chapter.create name: 'Chicago', time_zone_raw: 'Central Time (US & Canada)', code:"0542", short_name:"arcchi"

cook_county = Roster::County.create name:'Cook', fips_code:'031', vc_regex_raw:'cook', chapter:chicago_chapter
adams_county = Roster::County.create name:'Adams', fips_code:'001', vc_regex_raw:'adams', chapter:chicago_chapter
alexander_county = Roster::County.create name:'Alexander', fips_code:'003', vc_regex_raw:'alexander', chapter:chicago_chapter
dupage_county = Roster::County.create name:'Dupage', fips_code:'043', vc_regex_raw:'dupage',chapter:chicago_chapter

incident_admin = Roster::Role.create name:'admin', grant_name:'incidents_admin', chapter:chicago_chapter
chap_config = Roster::Role.create name:'chap_config', grant_name:'chapter_config', chapter:chicago_chapter
cas_admin = Roster::Role.create name:'cas_admin', grant_name:'cas_admin', chapter:chicago_chapter

dat_admin_position = Roster::Position.create name:'Chapter DAT Admin', chapter:chicago_chapter, roles:[incident_admin, chap_config, cas_admin]

dat_team_lead = Roster::Position.create name:'DAT Team Lead', vc_regex_raw:'Team Lead$', chapter:chicago_chapter
dat_trainee = Roster::Position.create name:'DAT Trainee', vc_regex_raw:'Trainee$', chapter:chicago_chapter
dat_dispatcher = Roster::Position.create name:'DAT Dispatcher', vc_regex_raw:'Dispatch$', chapter:chicago_chapter, roles:[cas_admin]


chuck = Roster::Person.create chapter:chicago_chapter, primary_county:cook_county, first_name:'Hon', last_name:'Chong', username:'admin', password_salt:"admin", cell_phone:'3125061270', address1:'604 W Sheridan Rd', city:'Chicago', state:'IL', zip:'60613', vc_is_active: false

Roster::CountyMembership.create person: chuck, county: cook_county
Roster::CountyMembership.create person: chuck, county: adams_county
Roster::PositionMembership.create position:dat_admin_position, person: chuck
Roster::PositionMembership.create position:dat_dispatcher, person: chuck
# Roster::CountyMembership.create person: bob, county: cook_county
# Roster::PositionMembership.create position:dat_team_lead, person: bob


#Scheduler::Shift.create county: sf, name: 'Team Lead', abbrev: 'TL', positions: [tl], shift_group: night, ordinal: 1, max_signups: 1


#load "lib/vc_importer.rb"; 
#vc = Roster::VCImporter.new; 
#vc.import_data(Roster::Chapter.first, "/Users/jlaxson/Downloads/LMSync1.xls")
#
#me = Roster::Person.find_by_last_name 'Laxson'
#me.email = 'jlaxson@mac.com'
#me.password = 'test123'
#me.save!