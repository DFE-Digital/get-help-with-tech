require 'rails_helper'

RSpec.describe ConfirmTechsourceAccountCreatedService do
  describe '#call' do
    context 'with one email' do
      let(:school) { create_schools_at_status(preorder_status: 'school_can_order') }
      let(:user) { create(:school_user, orders_devices: true, school: school) }
      let(:now) { Time.zone.now }

      subject(:service) { described_class.new(emails: [user.email_address]) }

      it 'updates user#techsource_account_confirmed_at to now' do
        expect(user.reload.techsource_account_confirmed_at).to be_nil

        Timecop.freeze(now) do
          service.call
          expect(user.reload.techsource_account_confirmed_at).to be_within(1.second).of(now)
        end
      end

      it 'adds email to processed list' do
        service.call

        expect(service.processed).to include(email: user.email_address)
      end

      context 'if there are devices orderable' do
        before do
          school.can_order!
        end

        it 'sends an email' do
          expect {
            service.call
          }.to have_enqueued_job.on_queue('mailers')
        end

        it 'only sends one email if touched multiple times' do
          expect {
            service.call
            service.call
          }.to have_enqueued_job.on_queue('mailers')
        end
      end

      context 'if there are no devices orderable' do
        before do
          stub_computacenter_outgoing_api_calls
          UpdateSchoolDevicesService.new(school: school,
                                         laptop_cap: 10,
                                         laptop_allocation: 10,
                                         laptops_ordered: 10).call
        end

        it 'does not send an email' do
          expect {
            service.call
          }.not_to have_enqueued_mail
        end
      end
    end

    context 'with multiple emails' do
      let(:user1) { create(:school_user) }
      let(:user2) { create(:school_user) }

      subject(:service) { described_class.new(emails: [user1.email_address, user2.email_address]) }

      it 'updates user#techsource_account_confirmed_at to truthy' do
        service.call

        expect(user1.reload.techsource_account_confirmed_at).to be_truthy
        expect(user2.reload.techsource_account_confirmed_at).to be_truthy
      end
    end

    context 'with non-existent email' do
      subject(:service) { described_class.new(emails: ['nobody@example.com']) }

      it 'adds email with message to unprocessed list' do
        service.call

        expect(service.unprocessed).to include(email: 'nobody@example.com', message: 'No user with this email found')
      end
    end

    context 'when user email has changed' do
      let!(:user) do
        create(:school_user, :relevant_to_computacenter, email_address: 'old@example.com')
      end

      before do
        user.update(email_address: 'new@example.com')
      end

      subject(:service) { described_class.new(emails: ['old@example.com']) }

      it 'updates user based on previous email' do
        expect(user.techsource_account_confirmed_at).to be_falsey
        service.call
        expect(user.reload.techsource_account_confirmed_at).to be_truthy
      end
    end

    context 'when user has been destroyed' do
      let(:school) { create(:school, computacenter_reference: '123456') }
      let!(:user) do
        create(:school_user, :relevant_to_computacenter, school: school)
      end

      before do
        user.destroy!
      end

      subject(:service) { described_class.new(emails: [user.email_address]) }

      it 'adds to processed list' do
        service.call

        expect(service.processed).to be_present
        expect(service.unprocessed).to be_empty
      end
    end
  end
end
