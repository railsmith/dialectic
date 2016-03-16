FactoryGirl.define do
  factory :mongoid_dialectic_post, class: 'Dialectic::Post' do
    subject "MyString"
    posted_by 1
    body "MyString"
  end
end
