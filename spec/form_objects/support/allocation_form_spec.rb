require 'rails_helper'

RSpec.describe Support::AllocationForm, type: :model do
  let(:order_state) { 'can_order' }

  let(:rb) do
    create(:local_authority,
           :manages_centrally,
           :vcap_feature_flag,
           computacenter_reference: '1000')
  end

  let!(:school) do
    create(:school,
           :centrally_managed,
           :with_std_device_allocation,
           :with_coms_device_allocation,
           order_state: order_state,
           computacenter_reference: '11',
           responsible_body: rb,
           laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 1,
           router_allocation: 4, router_cap: 3, routers_ordered: 0)
  end

  let!(:school2) do
    create(:school,
           :centrally_managed,
           :with_std_device_allocation,
           :with_coms_device_allocation,
           responsible_body: rb,
           order_state: 'can_order_for_specific_circumstances',
           computacenter_reference: '12',
           laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 1,
           router_allocation: 4, router_cap: 4, routers_ordered: 0)
  end

  before do
    stub_computacenter_outgoing_api_calls
  end

  describe '#save' do
    context 'when the school is in virtual cap pool' do
      let(:allocation) { 3 }
      let(:device_type) { :laptop }

      subject(:form) do
        described_class.new(allocation: allocation, device_type: device_type, school: school)
      end

      before do
        AddSchoolToVirtualCapPoolService.new(school).call
        AddSchoolToVirtualCapPoolService.new(school2).call
      end

      context 'when allocation increases' do
        let(:allocation) { 6 }

        it 'return false' do
          expect(form.save).to be_falsey
        end

        it 'do not modify any school ordering value' do
          expect { form.save }.not_to change(school, :order_state)
          expect { form.save }.not_to change(school, :laptop_allocation)
          expect { form.save }.not_to change(school, :router_allocation)
          expect { form.save }.not_to change(school, :router_cap)
          expect { form.save }.not_to change(school, :laptop_cap)
        end

        it 'add error to school field' do
          errors = {
            school: ['Decreasing an allocation for a school in a virtual cap pool is currently not possible - contact the dev team to do this manually for now'],
          }

          expect(form.save).to be_falsey

          expect(form.errors.messages).to eq(errors)
        end
      end

      context 'when allocation decreases below devices ordered' do
        let(:allocation) { 0 }

        it 'return false' do
          expect(form.save).to be_falsey
        end

        it 'do not modify any school ordering value' do
          expect { form.save }.not_to change(school, :order_state)
          expect { form.save }.not_to change(school, :laptop_allocation)
          expect { form.save }.not_to change(school, :router_allocation)
          expect { form.save }.not_to change(school, :router_cap)
          expect { form.save }.not_to change(school, :laptop_cap)
        end

        it 'add error to school field' do
          errors = {
            school: ['Allocation cannot be less than the number they have already ordered (1)'],
          }

          expect(form.save).to be_falsey

          expect(form.errors.messages).to eq(errors)
        end
      end

      it 'modify the school device raw allocation' do
        expect { form.save }.to change(school, :raw_laptop_allocation).from(5).to(3)
      end

      it 'modify the pool device allocation' do
        expect { form.save }.to change(school, :laptop_allocation).from(10).to(8)
      end

      context 'when the school cannot order' do
        let(:allocation) { 3 }
        let(:order_state) { 'cannot_order' }
        let(:requests) do
          [
            [
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '4' },
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '4' },
            ],
          ]
        end

        it 'update school device raw cap to match raw devices ordered' do
          expect { form.save }.to change(school, :raw_laptop_cap).from(4).to(1)
        end

        it 'update pool device cap' do
          expect { form.save }.to change(school, :laptop_cap).from(8).to(5)
        end

        it 'update pool school device cap on Computacenter' do
          expect(form.save).to be_truthy

          expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
        end

        it 'do not notify Computacenter by email' do
          expect { form.save }.not_to have_enqueued_mail(ComputacenterMailer)
        end

        it 'do not notify the school or support by email' do
          expect { form.save }.not_to have_enqueued_mail(CanOrderDevicesMailer)
        end
      end

      context 'when the school can order' do
        let(:allocation) { 3 }
        let(:order_state) { 'can_order' }
        let(:requests) do
          [
            [
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '7' },
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '7' },
            ],
          ]
        end

        it 'update school device raw cap to match device raw allocation' do
          expect { form.save }.to change(school, :raw_laptop_cap).from(4).to(3)
        end

        it 'update pool device cap' do
          expect { form.save }.to change(school, :laptop_cap).from(8).to(7)
        end

        it 'update pool school device cap on Computacenter' do
          expect(form.save).to be_truthy

          expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
        end

        it 'do not notify Computacenter by email' do
          expect { form.save }.not_to have_enqueued_mail(ComputacenterMailer)
        end

        it 'do not notify the school or support by email' do
          expect { form.save }.not_to have_enqueued_mail(CanOrderDevicesMailer)
        end
      end

      context 'when the school can order for specific circumstances' do
        let(:allocation) { 6 }
        let(:order_state) { 'can_order_for_specific_circumstances' }

        it 'do not update the school device raw cap' do
          byebug
          expect { form.save }.not_to change(school, :raw_laptop_cap)
        end

        it 'do not update pool device cap' do
          expect { form.save }.not_to change(school, :laptop_cap)
        end
      end
    end

    context 'when the school is not in virtual cap pool' do
      let(:allocation) { 3 }
      let(:device_type) { :laptop }

      subject(:form) do
        described_class.new(allocation: allocation, device_type: device_type, school: school)
      end

      context 'when allocation decreases below devices ordered' do
        let(:allocation) { 0 }

        it 'return false' do
          expect(form.save).to be_falsey
        end

        it 'do not modify any school ordering value' do
          expect { form.save }.not_to change(school, :order_state)
          expect { form.save }.not_to change(school, :laptop_allocation)
          expect { form.save }.not_to change(school, :router_allocation)
          expect { form.save }.not_to change(school, :router_cap)
          expect { form.save }.not_to change(school, :laptop_cap)
        end

        it 'add error to school field' do
          errors = {
            school: ['Allocation cannot be less than the number they have already ordered (1)'],
          }

          expect(form.save).to be_falsey

          expect(form.errors.messages).to eq(errors)
        end
      end

      it 'modify the school device allocation' do
        expect { form.save }.to change(school, :laptop_allocation).from(5).to(3)
      end

      context 'when the school cannot order' do
        let(:order_state) { 'cannot_order' }
        let(:requests) do
          [
            [
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '1' },
            ],
          ]
        end

        it 'update school device cap to match devices ordered' do
          expect { form.save }.to change(school, :laptop_cap).from(4).to(1)
        end

        it 'update school device cap on Computacenter' do
          expect(form.save).to be_truthy

          expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
        end

        it 'notify Computacenter of device cap change by email' do
          expect { form.save }
            .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
                  .with(params: { school: school, new_cap_value: 1 }, args: []).once
        end

        it 'do not notify the school users or support by email' do
          expect { form.save }.not_to have_enqueued_mail(CanOrderDevicesMailer)
        end

        it 'do not notify Computacenter of school can order by email' do
          expect { form.save }
            .not_to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order)
        end
      end

      context 'when the school can order' do
        let(:order_state) { 'can_order' }
        let(:requests) do
          [
            [
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '3' },
            ],
          ]
        end

        it 'update school device cap to match device allocation' do
          expect { form.save }.to change(school, :laptop_cap).from(4).to(3)
        end

        it 'update pool schools device cap on Computacenter' do
          expect(form.save).to be_truthy

          expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
        end

        it 'notify Computacenter of device cap change by email' do
          expect { form.save }
            .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
                  .with(params: { school: school, new_cap_value: 3 }, args: []).once
        end

        it "notify the school's organizational users" do
          user = create(:user, :relevant_to_computacenter, responsible_body: rb)

          expect { form.save }
            .to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_but_action_needed)
                  .with(params: { school: school, user: user }, args: []).once
        end

        it "notify support if no school's organizational users" do
          expect { form.save }
            .to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted)
                  .with(params: { school: school }, args: []).once
        end

        it 'notify Computacenter of school can order by email' do
          expect { form.save }
            .to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order)
                  .with(params: { school: school, new_cap_value: 3 }, args: []).once
        end
      end

      context 'when the school can order for specific circumstances' do
        let(:allocation) { 6 }
        let(:order_state) { 'can_order_for_specific_circumstances' }

        it 'do not update pool laptop cap' do
          expect { form.save }.not_to change(school, :laptop_cap)
        end

        it 'do not update pool router cap' do
          expect { form.save }.not_to change(school, :router_cap)
        end

        it 'do not update caps on Computacenter' do
          expect_not_to_have_sent_caps_to_computacenter
        end
      end
    end
  end
end
