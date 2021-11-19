require 'rails_helper'

RSpec.describe CapUpdateNotificationsService, type: :model do
  let(:notify_computacenter) { true }
  let(:notify_school) { true }
  let(:rb_computacenter_reference) { '1000' }

  before { stub_computacenter_outgoing_api_calls }

  describe '#call' do
    let(:rb) do
      create(:local_authority,
             :manages_centrally,
             :vcap,
             computacenter_reference: rb_computacenter_reference)
    end

    let!(:school) do
      create(:school,
             :centrally_managed,
             :in_lockdown,
             computacenter_reference: '11',
             responsible_body: rb,
             laptops: [1, 1, 0],
             routers: [1, 1, 1])
    end

    subject(:service) do
      described_class.new(school,
                          device_types: %i[laptop router],
                          notify_computacenter: notify_computacenter,
                          notify_school: notify_school)
    end

    context 'when there are no schools with complete computacenter references' do
      let(:rb_computacenter_reference) {}

      before { rb.calculate_vcaps! }

      specify { expect(service.call).to be_truthy }

      it 'do not update caps on Computacenter' do
        service.call

        expect_not_to_have_sent_caps_to_computacenter
      end

      it 'do not notify Computacenter by email' do
        expect { service.call }.not_to have_enqueued_mail(ComputacenterMailer)
      end

      it 'do not notify the school' do
        expect { service.call }.not_to have_enqueued_mail(CanOrderDevicesMailer)
      end
    end

    context 'when computacenter setting to inform Computacenter of cap changes is falsey' do
      before do
        allow(Settings.computacenter.outgoing_api).to receive(:endpoint).and_return(nil)
        rb.calculate_vcaps!
      end

      specify { expect(service.call).to be_truthy }

      it 'do not update caps on Computacenter' do
        service.call

        expect_not_to_have_sent_caps_to_computacenter
      end

      it 'do not notify Computacenter by email' do
        expect { service.call }.not_to have_enqueued_mail(ComputacenterMailer)
      end

      it 'do not notify the school' do
        expect { service.call }.not_to have_enqueued_mail(CanOrderDevicesMailer)
      end
    end

    context 'when cap updates to Computacenter succeed' do
      let(:requests) do
        [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '0' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '11', 'capAmount' => '1' },
          ],
        ]
      end

      specify { expect(service.call).to be_truthy }

      it 'update caps on Computacenter' do
        service.call

        expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
      end

      it 'notify Computacenter of laptops cap change by email' do
        expect { service.call }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
                .with(params: { school: school, new_cap_value: 0 }, args: []).once
      end

      it 'notify Computacenter of routers cap change by email' do
        expect { service.call }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_comms_cap_change)
                .with(params: { school: school, new_cap_value: 0 }, args: []).once
      end

      it "notify the school's organizational users" do
        user = create(:user, :relevant_to_computacenter, responsible_body: rb)
        rb.calculate_vcaps!

        expect { service.call }
          .to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_but_action_needed)
                .with(params: { school: school, user: user }, args: []).once
      end

      it "notify support if no school's organizational users" do
        rb.calculate_vcaps!

        expect { service.call }
          .to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted)
                .with(params: { school: school }, args: []).once
      end

      it 'notify Computacenter of school can order by email' do
        rb.calculate_vcaps!

        expect { service.call }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order)
                .with(params: { school: school, new_cap_value: 1 }, args: []).once
      end

      context 'when :notify_computacenter falsey' do
        let(:notify_computacenter) { false }

        it 'do not notify Computacenter by email' do
          expect { service.call }.not_to have_enqueued_mail(ComputacenterMailer)
        end

        it "notify the school's organizational users" do
          user = create(:user, :relevant_to_computacenter, responsible_body: rb)
          rb.calculate_vcaps!

          expect { service.call }
            .to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_but_action_needed)
                  .with(params: { school: school, user: user }, args: []).once
        end

        it "notify support if no school's organizational users" do
          rb.calculate_vcaps!

          expect { service.call }
            .to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted)
                  .with(params: { school: school }, args: []).once
        end
      end

      context 'when :notify_school falsey' do
        let(:notify_school) { false }

        before { rb.calculate_vcaps! }

        it 'notify Computacenter of laptops cap change by email' do
          expect { service.call }
            .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
                  .with(params: { school: school, new_cap_value: 1 }, args: []).once
        end

        it 'notify Computacenter of routers cap change by email' do
          expect { service.call }
            .to have_enqueued_mail(ComputacenterMailer, :notify_of_comms_cap_change)
                  .with(params: { school: school, new_cap_value: 1 }, args: []).once
        end

        it 'do not notify Computacenter of school can order by email' do
          expect { service.call }
            .not_to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order)
        end

        it 'do not notify the school or support' do
          expect { service.call }.not_to have_enqueued_mail(CanOrderDevicesMailer)
        end
      end
    end
  end
end
