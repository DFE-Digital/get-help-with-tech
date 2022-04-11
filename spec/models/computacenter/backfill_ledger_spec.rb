require 'rails_helper'

RSpec.describe Computacenter::BackfillLedger do
  subject(:service) { described_class.new }

  before do
    Computacenter::UserChange.delete_all
  end

  describe '#call when not initalized with given users' do
    context 'happy path' do
      let!(:user) { create(:local_authority_user, :has_seen_privacy_notice, orders_devices: true) }
      let(:now) { Time.zone.now.utc }

      it 'persists user to ledger' do
        Computacenter::UserChange.delete_all
        expect { service.call }.to change(Computacenter::UserChange, :count).by(1)
      end

      it 'creates change record correctly' do
        Timecop.freeze(now) do
          service.call
        end

        user_change = Computacenter::UserChange.last

        expect(user_change.user_id).to eql(user.id)
        expect(user_change.first_name).to eql(user.first_name)
        expect(user_change.last_name).to eql(user.last_name)
        expect(user_change.email_address).to eql(user.email_address)
        expect(user_change.telephone).to eql(user.telephone)
        expect(user_change.responsible_body).to eql(user.effective_responsible_body.name)
        expect(user_change.responsible_body_urn).to eql(user.effective_responsible_body.computacenter_identifier)
        expect(user_change.cc_sold_to_number).to eql(user.effective_responsible_body.computacenter_reference)
        expect(user_change.school).to be_blank
        expect(user_change.school_urn).to be_blank
        expect(user_change.cc_ship_to_number).to be_blank
        expect(user_change.updated_at_timestamp).to be_within(1.second).of(now)
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
        Computacenter::UserChange.delete_all
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

  describe '#call when initialized with a set of users' do
    let(:responsible_body) { create(:local_authority) }
    let(:given_users) { responsible_body.users }

    subject(:service) { described_class.new(users: given_users) }

    before do
      create_list(:user, 3, responsible_body:)
      school = create(:school)
      create_list(:user, 2, school:, orders_devices: true)
      other_responsible_body = create(:local_authority)
      create_list(:user, 5, :has_seen_privacy_notice, orders_devices: true, responsible_body: other_responsible_body)
      Computacenter::UserChange.delete_all
    end

    it 'backfills the ledger with just the given users' do
      expect { service.call }.to change(Computacenter::UserChange, :count).by(3)
      expect(Computacenter::UserChange.pluck(:email_address).sort).to eq(given_users.pluck(:email_address).sort)
    end
  end
end
