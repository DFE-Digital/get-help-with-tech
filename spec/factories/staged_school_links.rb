FactoryBot.define do
  factory :staged_school_link, class: 'DataStage::SchoolLink' do
    staged_school
    link_urn { 103_001 }
    link_type { 'successor' }

    trait :predecessor do
      link_type { 'predecessor' }
    end
  end
end
