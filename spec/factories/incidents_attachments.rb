# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_attachment, :class => 'Incidents::Attachment' do
    incident nil
    person nil
    name "MyString"
    description "MyString"
    attachment_type "MyString"
  end
end