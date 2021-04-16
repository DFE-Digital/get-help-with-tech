FactoryBot.define do
  factory :allocation_batch_job do
    batch_id { SecureRandom.uuid }
    allocation_delta { rand(1..100) }
  end
end
