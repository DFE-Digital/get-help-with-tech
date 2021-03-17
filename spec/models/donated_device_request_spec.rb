require 'rails_helper'

RSpec.describe DonatedDeviceRequest, type: :model do
  context 'when created by a responsible body' do
    it 'validates opt_in_choice is correct when the status is opt_in_step' do
      request = build(:donated_device_request, :for_responsible_body)
      expect(request.valid?).to be true

      request.status = 'opt_in_step'
      expect(request.valid?).to be false
      expect(request.errors[:opt_in_choice]).to be_present

      request.opt_in_choice = 'some_schools'
      expect(request.valid?).to be true
    end

    it 'validates schools are present when the status is schools_step or complete' do
      schools = create_list(:school, 2)
      request = build(:donated_device_request, :for_responsible_body, :opt_in_all, :wants_laptops, :wants_full_amount)
      expect(request.valid?).to be true

      request.status = 'schools_step'
      expect(request.valid?).to be false
      expect(request.errors[:schools]).to be_present

      request.status = 'complete'
      expect(request.valid?).to be false
      expect(request.errors[:schools]).to be_present

      request.schools = schools.map(&:id)
      expect(request.valid?).to be true
    end

    it 'validates device_types are correct when the status is devices_step or complete' do
      school = create(:school)
      request = build(:donated_device_request, :for_responsible_body, schools: [school.id])
      request.device_types = %w[windows android-tablet chromebook ipad]
      expect(request.valid?).to be true
      request.device_types << 'biscuit'
      expect(request.valid?).to be true
      request.status = 'devices_step'
      expect(request.valid?).to be false
      expect(request.errors[:device_types]).to be_present
      request.status = 'complete'
      expect(request.valid?).to be false
      expect(request.errors[:device_types]).to be_present
    end

    it 'validates units are present when the status is units-step or complete' do
      school = create(:school)
      request = build(:donated_device_request, :for_responsible_body, :wants_laptops, schools: [school.id], units: nil)
      expect(request.valid?).to be true
      request.status = 'units_step'
      expect(request.valid?).to be false
      expect(request.errors[:units]).to be_present
      request.status = 'incomplete'
      expect(request.valid?).to be true
      request.status = 'complete'
      expect(request.valid?).to be false
      expect(request.errors[:units]).to be_present
    end
  end

  context 'when created by a school' do
    it 'validates device_types are correct' do
      school = create(:school)
      request = build(:donated_device_request, schools: [school.id])
      request.device_types = %w[windows android-tablet chromebook ipad]
      expect(request.valid?).to be true
      request.device_types << 'biscuit'
      expect(request.valid?).to be false
      expect(request.errors[:device_types]).to be_present
    end

    it 'validates units are present when the status is units-step or complete' do
      school = create(:school)
      request = build(:donated_device_request, :wants_laptops, schools: [school.id], units: nil)
      expect(request.valid?).to be true
      request.status = 'units_step'
      expect(request.valid?).to be false
      expect(request.errors[:units]).to be_present
      request.status = 'incomplete'
      expect(request.valid?).to be true
      request.status = 'complete'
      expect(request.valid?).to be false
      expect(request.errors[:units]).to be_present
    end
  end

  describe '#mark_as_complete' do
    let(:school) { create(:school) }

    subject(:model) { build(:donated_device_request, :wants_laptops, :opt_in_all, :wants_full_amount, schools: [school.id]) }

    it 'sets status as complete and completed_at stamp' do
      model.mark_as_complete!
      expect(model.status).to eql('complete')
      expect(model.completed_at).to be_within(10.seconds).of(Time.zone.now)
    end
  end
end
