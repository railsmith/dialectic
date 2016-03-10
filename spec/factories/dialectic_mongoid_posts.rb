FactoryGirl.define do
  factory :dialectic_mongoid_post, class: 'Dialectic::Mongoid::Post' do
    subject "MyString"
    posted_by 1
    body "MyString"
  end
end
