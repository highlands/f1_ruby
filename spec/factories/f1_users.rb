FactoryGirl.define do

  factory :f1_user, :class => 'F1::User' do
    username "MyString"
    token "MyString"
    secret "MyString"
  end

end
