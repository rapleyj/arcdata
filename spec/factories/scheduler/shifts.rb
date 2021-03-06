# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift, :class => 'Scheduler::Shift' do
    name {"Some Shift #{Faker::Name.first_name}"}
    association :county
    shift_group { |s| s.association :shift_group, chapter: s.county.chapter }
    max_signups 1
    min_desired_signups 1
    abbrev 'SH'
  end
end
