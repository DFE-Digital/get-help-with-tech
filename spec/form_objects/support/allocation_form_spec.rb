require 'rails_helper'

RSpec.describe Support::AllocationForm, type: :model do
  before do
    stub_computacenter_outgoing_api_calls
  end

  describe '#save' do
    let(:order_state) { 'can_order' }

    let!(:school) do
      create(:school,
             :centrally_managed,
             order_state: order_state,
             computacenter_reference: '11',
             responsible_body: rb,
             laptops: [5, 4, 1],
             routers: [4, 3, 0])
    end

    before do
      create(:school,
             :centrally_managed,
             responsible_body: rb,
             order_state: 'can_order_for_specific_circumstances',
             computacenter_reference: '12',
             laptops: [5, 4, 1],
             routers: [4, 4, 0])
    end

    context 'when the school is in virtual cap pool' do
      let(:allocation) { 6 }
      let(:device_type) { :laptop }
      let(:rb) do
        create(:local_authority,
               :manages_centrally,
               :vcap,
               computacenter_reference: '1000')
      end

      subject(:form) do
        described_class.new(allocation: allocation, device_type: device_type, school: school)
      end

      before { rb.calculate_vcaps! }

      context 'when allocation decreases' do
        let(:allocation) { 4 }

        it 'return false' do
          expect(form.save).to be_falsey
        end

        it 'do not modify any school ordering value' do
          expect { form.save }.not_to change(school, :order_state)
          expect { form.save }.not_to(change { school.allocation(:laptop) })
          expect { form.save }.not_to(change { school.allocation(:router) })
          expect { form.save }.not_to(change { school.cap(:router) })
          expect { form.save }.not_to(change { school.cap(:laptop) })
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
          expect { form.save }.not_to(change { school.allocation(:laptop) })
          expect { form.save }.not_to(change { school.allocation(:router) })
          expect { form.save }.not_to(change { school.cap(:router) })
          expect { form.save }.not_to(change { school.cap(:laptop) })
        end

        it 'add error to school field' do
          error = 'Allocation cannot be less than the number they have already ordered (1)'

          expect(form.save).to be_falsey
          expect(form.errors.messages[:school]).to include(error)
        end
      end

      it 'modify the school device raw allocation' do
        expect { form.save }.to change { school.raw_allocation(:laptop) }.from(5).to(6)
      end

      it 'modify the pool device allocation' do
        expect { form.save }.to change { school.allocation(:laptop) }.from(10).to(11)
      end

      it 'do not notify Computacenter by email' do
        expect { form.save }.not_to have_enqueued_mail(ComputacenterMailer)
      end

      it 'do not notify the school or support by email' do
        expect { form.save }.not_to have_enqueued_mail(CanOrderDevicesMailer)
      end

      context 'when the school cannot order' do
        let(:allocation) { 6 }
        let(:order_state) { 'cannot_order' }
        let(:requests) do
          [
            [
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '4' },
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '4' },
            ],
          ]
        end

        it 'do not change school device raw cap' do
          expect(school.raw_cap(:laptop)).to be(1)
          expect { form.save }.not_to(change { school.reload.raw_cap(:laptop) })
        end

        it 'the pool device cap remains unchanged' do
          expect(school.cap(:laptop)).to be(5)
          expect { form.save }.not_to(change { school.cap(:laptop) })
        end

        it 'update pool school device cap on Computacenter' do
          expect(form.save).to be_truthy

          expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
        end
      end

      %w[can_order can_order_for_specific_circumstances].each do |can_order_state|
        context "when the school #{can_order_state}" do
          let(:allocation) { 6 }
          let(:order_state) { can_order_state }
          let(:requests) do
            [
              [
                { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '8' },
                { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '8' },
              ],
            ]
          end

          it 'update school device raw cap with allocation delta' do
            expect { form.save }.to change { school.raw_cap(:laptop) }.from(4).to(5)
          end

          it 'update pool device cap' do
            expect { form.save }.to change { school.cap(:laptop) }.from(8).to(9)
          end

          it 'update pool school device cap on Computacenter' do
            expect(form.save).to be_truthy

            expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
          end
        end
      end
    end

    context 'when the school is not in virtual cap pool' do
      let(:allocation) { 3 }
      let(:device_type) { :laptop }
      let(:rb) do
        create(:local_authority,
               :manages_centrally,
               computacenter_reference: '1000')
      end

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
          expect { form.save }.not_to(change { school.allocation(:laptop) })
          expect { form.save }.not_to(change { school.allocation(:router) })
          expect { form.save }.not_to(change { school.cap(:router) })
          expect { form.save }.not_to(change { school.cap(:laptop) })
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
        expect { form.save }.to change { school.allocation(:laptop) }.from(5).to(3)
      end

      context 'when the school cannot order' do
        let(:order_state) { 'cannot_order' }

        it 'do not update school raw device cap' do
          expect { form.save }.not_to(change { school.raw_cap(:laptop) })
        end

        it 'do not change school device cap' do
          expect(school.cap(:laptop)).to eq(1)
          expect { form.save }.not_to(change { school.cap(:laptop) })
        end

        it 'do not update school device cap on Computacenter as it has not changed' do
          expect(school.computacenter_cap(:laptop)).to eq(1)
          expect(form.save).to be_truthy
          expect(school.computacenter_cap(:laptop)).to eq(1)
          expect_not_to_have_sent_caps_to_computacenter
        end

        it 'do not notify Computacenter of device cap change by email' do
          expect { form.save }.not_to have_enqueued_mail(ComputacenterMailer)
        end

        it 'do not notify the school users or support by email' do
          expect { form.save }.not_to have_enqueued_mail(CanOrderDevicesMailer)
        end

        it 'do not notify Computacenter of school can order by email' do
          expect { form.save }
            .not_to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order)
        end
      end

      %w[can_order can_order_for_specific_circumstances].each do |can_order_state|
        context "when the school #{can_order_state}" do
          let(:order_state) { can_order_state }
          let(:requests) do
            [
              [
                { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '2' },
              ],
            ]
          end

          it 'update school raw device cap by allocation delta' do
            expect { form.save }.to change { school.cap(:laptop) }.from(4).to(2)
          end

          it 'update pool schools device cap on Computacenter' do
            expect(form.save).to be_truthy

            expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
          end

          it 'notify Computacenter of device cap change by email' do
            expect { form.save }
              .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
                    .with(params: { school: school, new_cap_value: 2 }, args: []).once
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
                    .with(params: { school: school, new_cap_value: 2 }, args: []).once
          end
        end
      end
    end
  end
end
