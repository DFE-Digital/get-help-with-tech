require 'rails_helper'

RSpec.describe DataStage::School, type: :model do
  subject(:school) { create(:staged_school) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:urn) }
    it { is_expected.to allow_values('123456', '432123').for(:urn) }
    it { is_expected.not_to allow_values('1234567', '123', '12AW22').for(:urn) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:responsible_body_name) }
    it { is_expected.to allow_values('open', 'closed').for(:status) }
    it { is_expected.to allow_values('primary', 'secondary', 'all_through', 'sixteen_plus', 'nursery', 'phase_not_applicable').for(:phase) }
    it { is_expected.to allow_values('academy', 'free', 'local_authority', 'special', 'other_type').for(:establishment_type) }
  end

  it 'has predecessor schools when there are predecessor links' do
    expect(school.predecessors).to be_empty

    predecessor_school = create(:school)
    school.school_links << build(:staged_school_link, :predecessor, link_urn: predecessor_school.urn)

    expect(school.predecessors).to eq([predecessor_school])
  end
end
