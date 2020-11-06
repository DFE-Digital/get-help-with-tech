require 'rails_helper'

RSpec.describe Computacenter::UserChangeGenerator do
  context 'when RB is updated and affects a user' do
    let(:rb) { create(:trust, computacenter_reference: nil) }

    before do
      create(:trust_user, :relevant_to_computacenter, responsible_body: rb)
    end

    it 'generates a user change' do
      expect {
        rb.update!(computacenter_reference: 'ABC')
      }.to change(Computacenter::UserChange, :count).by(1)

      user_change = Computacenter::UserChange.last
      expect(user_change.cc_sold_to_number).to eql('ABC')
    end
  end

  context 'when school is updated and affects a user' do
    let(:school) { create(:school, computacenter_reference: nil) }

    before do
      create(:school_user, :relevant_to_computacenter, school: school)
    end

    it 'generates a user change' do
      expect {
        school.update!(computacenter_reference: 'ABC')
      }.to change(Computacenter::UserChange, :count).by(1)

      user_change = Computacenter::UserChange.last
      expect(user_change.cc_ship_to_number).to eql('ABC')
    end
  end
end
