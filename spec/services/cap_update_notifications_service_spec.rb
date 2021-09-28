require 'rails_helper'

RSpec.describe CapUpdateNotificationsService, type: :model do
  let(:notify_computacenter) { true }
  let(:notify_school) { true }

  describe '#call' do
    let(:rb) do
      create(:local_authority,
             :manages_centrally,
             :vcap_feature_flag,
             computacenter_reference: '1000')
    end

    let!(:school) do
      create(:school,
             :centrally_managed,
             :in_lockdown,
             :with_std_device_allocation,
             :with_coms_device_allocation,
             computacenter_reference: '11',
             responsible_body: rb,
             laptop_allocation: 50, laptop_cap: 35, laptops_ordered: 10,
             router_allocation: 5, router_cap: 3, routers_ordered: 1)
    end

    let(:allocations) { [school.std_device_allocation, school.coms_device_allocation] }

    subject(:service) do
      described_class.new(*allocations.map(&:id),
                          notify_computacenter: notify_computacenter,
                          notify_school: notify_school)
    end

    before { stub_computacenter_outgoing_api_calls }

    context 'when there are no schools with complete computacenter references' do
      before do
        rb.update(computacenter_reference: nil)
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

    context 'when computacenter setting to inform Computacenter of cap changes is falsey' do
      before do
        allow(Settings.computacenter.outgoing_api).to receive(:endpoint).and_return(nil)
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
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '35' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '11', 'capAmount' => '3' },
          ],
        ]
      end

      specify { expect(service.call).to be_truthy }

      it 'update caps on Computacenter' do
        service.call

        expect_to_have_sent_caps_to_computacenter(requests)
      end

      it 'notify Computacenter of laptops cap change by email' do
        expect { service.call }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
                .with(params: { school: school, new_cap_value: 35 }, args: []).once
      end

      it 'notify Computacenter of routers cap change by email' do
        expect { service.call }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_comms_cap_change)
                .with(params: { school: school, new_cap_value: 3 }, args: []).once
      end

      it "notify the school's organizational users" do
        user = create(:user, :relevant_to_computacenter, responsible_body: rb)

        expect { service.call }
          .to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_but_action_needed)
                .with(params: { school: school, user: user }, args: []).once
      end

      it "notify support if no school's organizational users" do
        expect { service.call }
          .to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted)
                .with(params: { school: school }, args: []).once
      end

      it 'notify Computacenter of school can order by email' do
        expect { service.call }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order)
                .with(params: { school: school, new_cap_value: 35 }, args: []).once
      end

      context 'when :notify_computacenter falsey' do
        let(:notify_computacenter) { false }

        it 'do not notify Computacenter by email' do
          expect { service.call }.not_to have_enqueued_mail(ComputacenterMailer)
        end

        it "notify the school's organizational users" do
          user = create(:user, :relevant_to_computacenter, responsible_body: rb)

          expect { service.call }
            .to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_but_action_needed)
                  .with(params: { school: school, user: user }, args: []).once
        end

        it "notify support if no school's organizational users" do
          expect { service.call }
            .to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted)
                  .with(params: { school: school }, args: []).once
        end
      end

      context 'when :notify_school falsey' do
        let(:notify_school) { false }

        it 'notify Computacenter of laptops cap change by email' do
          expect { service.call }
            .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
                  .with(params: { school: school, new_cap_value: 35 }, args: []).once
        end

        it 'notify Computacenter of routers cap change by email' do
          expect { service.call }
            .to have_enqueued_mail(ComputacenterMailer, :notify_of_comms_cap_change)
                  .with(params: { school: school, new_cap_value: 3 }, args: []).once
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
