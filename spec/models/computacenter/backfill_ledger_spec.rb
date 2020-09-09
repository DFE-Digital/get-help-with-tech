require 'rails_helper'

RSpec.describe Computacenter::BackfillLedger do
  subject(:service) { described_class.new }

  describe '#call' do
    context 'happy path' do
      let!(:user) { create(:local_authority_user, orders_devices: true) }

      it 'persists user to ledger' do
        expect { service.call }.to change(Computacenter::UserChange, :count).by(1)
      end

      it 'creates change record correctly' do
        service.call
        user_change = Computacenter::UserChange.last

        expect(user_change.user_id).to eql(user.id)
        expect(user_change.first_name).to eql(user.first_name)
        expect(user_change.last_name).to eql(user.last_name)
        expect(user_change.email_address).to eql(user.email_address)
        expect(user_change.telephone).to eql(user.telephone)
        expect(user_change.responsible_body).to eql(user.effective_responsible_body.name)
        expect(user_change.responsible_body_urn).to eql(user.effective_responsible_body.computacenter_identifier)
        expect(user_change.cc_sold_to_number).to eql(user.effective_responsible_body.computacenter_reference)
        expect(user_change.school).to eql(user.school&.name)
        expect(user_change.school_urn).to eql(user.school&.urn)
        expect(user_change.cc_ship_to_number).to eql(user.school&.computacenter_reference)
        expect(user_change.updated_at_timestamp).to eql(user.created_at)
        expect(user_change.type_of_update).to eql('New')
        expect(user_change.original_first_name).to be(nil)
        expect(user_change.original_last_name).to be(nil)
        expect(user_change.original_email_address).to be(nil)
        expect(user_change.original_telephone).to be(nil)
        expect(user_change.original_responsible_body).to be(nil)
        expect(user_change.original_responsible_body_urn).to be(nil)
        expect(user_change.original_cc_sold_to_number).to be(nil)
        expect(user_change.original_school).to be(nil)
        expect(user_change.original_school_urn).to be(nil)
        expect(user_change.original_cc_ship_to_number).to be(nil)
      end
    end

    context 'calling backfill multiple times' do
      before do
        create(:local_authority_user, orders_devices: true)
      end

      it 'does not persist multiple times' do
        expect {
          service.call
          service.call
        }.to change(Computacenter::UserChange, :count).by(1)
      end
    end

    context 'when user has not read privacy policy' do
      before do
        create(:local_authority_user, :has_not_seen_privacy_notice)
      end

      it 'does not backfill user to ledger' do
        expect { service.call }.not_to change(Computacenter::UserChange, :count)
      end
    end

    context 'when user cannot order devices' do
      before do
        create(:local_authority_user, orders_devices: false)
      end

      it 'does not backfill user to ledger' do
        expect { service.call }.not_to change(Computacenter::UserChange, :count)
      end
    end
  end
end
