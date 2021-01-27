require 'rails_helper'

RSpec.describe Support::SchoolSuggestionForm, type: :model do
  subject(:form) { described_class.new }

  it { is_expected.to validate_length_of(:name_or_urn_or_ukprn).is_at_least(3) }

  it 'allows name_or_urn_or_ukprn to be nil if school_urn is set' do
    expect(described_class.new(school_urn: '123456')).to be_valid
  end

  it 'returns a set of matching schools from a search string' do
    school1 = create(:school, name: 'Southmead School')
    school2 = create(:school, name: 'Southdean School')
    create(:school, name: 'Northfields School')

    form = Support::SchoolSuggestionForm.new(name_or_urn_or_ukprn: 'South')

    expect(form.matching_schools).to contain_exactly(school1, school2)
  end

  it 'limits the number of matched results to a hardcoded maximum' do
    stub_const 'Support::SchoolSuggestionForm::MAX_NUMBER_OF_SUGGESTED_SCHOOLS', 2

    create_list(:school, 4, name: 'AA School')

    form = Support::SchoolSuggestionForm.new(name_or_urn_or_ukprn: 'AA')

    expect(form.maximum_matching_schools).to eq(2)
    expect(form.matching_schools.size).to eq(2)
    expect(form.matching_schools_capped?).to be_truthy
  end

  it 'returns an exact match on the school URN when one is provided' do
    matching_school = create(:school, name: 'Southmead School', urn: 123_456)
    create(:school, name: 'Southdean School', urn: 654_321)

    form = Support::SchoolSuggestionForm.new(school_urn: '123456')

    expect(form.matching_schools).to contain_exactly(matching_school)
  end

  it 'excludes specified schools from the results when that parameter is present' do
    matching_school = create(:school, name: 'Southmead School', urn: 123_456)
    excluded_school = create(:school, name: 'Southdean School', urn: 654_321)

    form = Support::SchoolSuggestionForm.new(name_or_urn_or_ukprn: 'South', except: [excluded_school])

    expect(form.matching_schools).to contain_exactly(matching_school)
  end
end
