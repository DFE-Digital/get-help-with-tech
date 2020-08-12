FactoryBot.define do
  factory :api_token do
    association :user, factory: :computacenter_user
    name { user.full_name + '\'s token ' + (Time.now.to_f * 1000).to_i.to_s }
    status { APIToken.statuses.keys.sample }
    token { SecureRandom.uuid }
    
    trait :active do
      status { 'active' }
    end
    trait :revoked do
      status { 'revoked' }
    end
  end
end
