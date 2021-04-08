FactoryBot.define do
  factory :allocation_batch_job do
    batch_id { SecureRandom.uuid }
  end
end
