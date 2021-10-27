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
        school.reload.update!(computacenter_reference: 'ABC')
      }.to change(Computacenter::UserChange, :count).by(1)

      user_change = Computacenter::UserChange.last
      expect(user_change.cc_ship_to_number).to eql('ABC')
    end
  end

  describe '#is_addition?' do
    subject(:generator) { described_class.new(user) }

    context 'when the user is relevant_to_computacenter' do
      let(:user) { create(:school_user, :relevant_to_computacenter) }

      context 'and the user has not been soft_deleted' do
        before do
          user.update!(deleted_at: nil)
        end

        context 'and there is no existing UserChange for the user' do
          before do
            Computacenter::UserChange.where(user_id: user.id).delete_all
          end

          it 'returns true' do
            expect(generator.send(:is_addition?)).to eq(true)
          end
        end

        context 'and there is an existing UserChange for the user of type Remove' do
          before do
            Computacenter::UserChange.create(user: user, type_of_update: 'Remove')
          end

          it 'returns true' do
            expect(generator.send(:is_addition?)).to eq(true)
          end
        end
      end

      context 'when the user has been soft_deleted' do
        before do
          user.update!(deleted_at: 1.day.ago)
        end

        context 'and there is an existing UserChange for the user of type Remove' do
          before do
            Computacenter::UserChange.create(user: user, type_of_update: 'Remove')
          end

          it 'returns false' do
            expect(generator.send(:is_addition?)).to eq(false)
          end
        end
      end
    end

    context 'when the user is not relevant_to_computacenter' do
      let(:user) { create(:user, orders_devices: false) }

      it 'returns false' do
        expect(generator.send(:is_addition?)).to eq(false)
      end
    end
  end
end
