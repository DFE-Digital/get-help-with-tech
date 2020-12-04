require 'rails_helper'

RSpec.describe Support::NewUserSchoolForm, type: :model do
  subject(:form) { described_class.new }

  it 'returns a set of matching schools from a search string' do
    school1 = create(:school, name: 'Southmead School')
    school2 = create(:school, name: 'Southdean School')
    create(:school, name: 'Northfields School')

    form = Support::NewUserSchoolForm.new(name_or_urn: 'South')

    expect(form.matching_schools).to contain_exactly(school1, school2)
  end

  it 'limits the number of matched results to a hardcoded maximum' do
    stub_const 'Support::NewUserSchoolForm::MAX_NUMBER_OF_SUGGESTED_SCHOOLS', 2

    create_list(:school, 4, name: 'AA School')

    form = Support::NewUserSchoolForm.new(name_or_urn: 'AA')

    expect(form.matching_schools.size).to eq(2)
  end

  it 'returns an exact match on the school URN when one is provided' do
    matching_school = create(:school, name: 'Southmead School', urn: 123_456)
    create(:school, name: 'Southdean School', urn: 654_321)

    form = Support::NewUserSchoolForm.new(school_urn: '123456')

    expect(form.matching_schools).to contain_exactly(matching_school)
  end
end
