require 'rails_helper'

RSpec.describe OnboardSingleSchoolResponsibleBodyService, type: :model do
  before do
    # disable computacenter user import API calls
    allow(Settings.computacenter.service_now_user_import_api).to receive(:endpoint).and_return(nil)
    stub_computacenter_outgoing_api_calls
  end

  after do
    clear_enqueued_jobs
  end

  let(:responsible_body) { create(:trust, :single_academy_trust) }
  let(:school) { create(:school, responsible_body: responsible_body) }

  context 'cases when the service does not apply' do
    it 'returns without creating any new users if the responsible body has multiple schools' do
      create(:school, responsible_body: responsible_body) # another school in the RB
      create(:school_contact, :headteacher, school: school)

      expect { described_class.new(urn: school.urn).call }
        .not_to change { User.count }.from(0)
    end

    it 'raises an error if the passed URN cannot be found' do
      expect { described_class.new(urn: '12345').call }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an error if the responsible body has no users and the school has no headteacher' do
      expect {
        described_class.new(urn: school.urn).call
      }.to raise_error(/Cannot continue without RB users or a school headteacher/)
    end
  end

  context 'when the responsible body has users' do
    before do
      create_list(:trust_user, 4, responsible_body: responsible_body, orders_devices: true)
      described_class.new(urn: school.urn).call
      responsible_body.reload
      school.reload
    end

    it 'marks the responsible body as having devolved ordering to schools' do
      expect(responsible_body.who_will_order_devices).to eq('school')
    end

    it 'sets one of the users as a school contact' do
      expect(school.current_contact).to be_present

      contact_email_address = school.current_contact.email_address
      expect(responsible_body.users.find_by(email_address: contact_email_address)).to be_present
    end

    it 'contacts the school contact and marks the school as contacted' do
      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.first.to.first).to eq(school.current_contact.email_address)
      expect(school.preorder_status).to eq('school_contacted')
    end

    it 'contacts all RB users' do
      perform_enqueued_jobs

      contacted_emails = ActionMailer::Base.deliveries.flat_map(&:to)
      expect(contacted_emails).to match_array(responsible_body.users.map(&:email_address))
    end

    it 'ensures that only 3 of the RB users are going to order devices' do
      # it's a bit strange that some users have their ability to order randomly switched off,
      # but there's no other obvious way to decide who to ensure the '3 Techsource users' constraint
      expect(responsible_body.users.who_can_order_devices.count).to eq(3)
    end

    it 'adds all the RB users as school users' do
      User.all.each do |user|
        expect(user.single_school_user?).to be_truthy
        expect(user.school).to eq(school)
        expect(user.responsible_body).to eq(responsible_body)
      end
    end
  end

  context 'when the headteacher is already one of the responsible body users' do
    before do
      @headteacher = create(:school_contact, :headteacher, school: school)

      create(:trust_user,
             email_address: @headteacher.email_address,
             full_name: @headteacher.full_name,
             responsible_body: responsible_body,
             orders_devices: true)

      described_class.new(urn: school.urn).call
      responsible_body.reload
      school.reload
    end

    it 'contacts the headteacher and marks the school as contacted' do
      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.first.to.first).to eq(@headteacher.email_address)
      expect(school.preorder_status).to eq('school_contacted')
    end

    it 'makes the headteacher a school user' do
      expect(User.find_by(email_address: @headteacher.email_address).is_school_user?).to be_truthy
    end
  end

  context 'when the responsible body has no users but the school has a headteacher contact' do
    before do
      @headteacher = create(:school_contact, :headteacher, school: school)

      described_class.new(urn: school.urn).call
      responsible_body.reload
      school.reload
    end

    it 'marks the responsible body as having devolved ordering to schools' do
      expect(responsible_body.who_will_order_devices).to eq('school')
    end

    it 'sets the headteacher as a school contact' do
      expect(school.current_contact).to eq(@headteacher)
    end

    it 'contacts the headteacher and marks the school as contacted' do
      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.first.to.first).to eq(@headteacher.email_address)
      expect(school.preorder_status).to eq('school_contacted')
    end

    it 'adds the headteacher as a single_academy_trust user who can order' do
      user = User.find_by!(email_address: @headteacher.email_address)

      expect(user.single_school_user?).to be_truthy
      expect(user.school).to eq(school)
      expect(user.responsible_body).to eq(responsible_body)
    end
  end

  context 'when the headteacher email address has upper-case letters' do
    before do
      @headteacher = create(:school_contact, :headteacher,
                            school: school,
                            email_address: 'JSmith@school.sch.uk')

      described_class.new(urn: school.urn).call
      responsible_body.reload
      school.reload
    end

    it 'adds the headteacher as a single_academy_trust user who can order under their lowercase email' do
      user = User.find_by!(email_address: 'jsmith@school.sch.uk')

      expect(user.single_school_user?).to be_truthy
      expect(user.school).to eq(school)
      expect(user.responsible_body).to eq(responsible_body)
    end
  end
end
