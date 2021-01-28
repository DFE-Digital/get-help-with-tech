require 'rails_helper'

RSpec.describe ChromebookInformationForm do
  it 'handles whitespace in the email address' do
    stub_request(:get, 'https://www.google.com/a/school.sch.uk/ServiceLogin')
      .to_return(status: 200, body: '', headers: {})

    form = described_class.new(will_need_chromebooks: 'yes',
                               recovery_email_address: ' ab@c.com ',
                               school_or_rb_domain: 'school.sch.uk')

    form.validate

    expect(form.errors[:recovery_email_address]).to be_blank
    expect(form.recovery_email_address).to eq('ab@c.com')
  end

  it 'handles whitespace in the school/RB domain' do
    request = stub_request(:get, 'https://www.google.com/a/school.sch.uk/ServiceLogin')
      .to_return(status: 200, body: '', headers: {})

    form = described_class.new(will_need_chromebooks: 'yes',
                               recovery_email_address: 'ab@c.com',
                               school_or_rb_domain: ' school.sch.uk ')

    form.validate

    expect(request).to have_been_made
  end

  describe '#chromebook_domain_label' do
    let(:school) { build(:school, :la_maintained) }
    let(:form) { described_class.new(school: school) }

    it 'starts with the capitalized institution_type' do
      expect(form.chromebook_domain_label).to start_with('School')
    end

    it 'ends with email domain registered for <span class="app-no-wrap">G Suite for Education</span>' do
      expect(form.chromebook_domain_label).to end_with('email domain registered for <span class="app-no-wrap">G Suite for Education</span>')
    end

    context 'when the school is not a FurtherEducationSchool' do
      context 'and the responsible body is a local authority' do
        it 'starts with School or local authority' do
          expect(form.chromebook_domain_label).to start_with('School or local authority')
        end
      end

      context 'and the responsible body is a trust' do
        let(:school) { build(:school, :academy) }

        it 'starts with School or local authority' do
          expect(form.chromebook_domain_label).to start_with('School or trust')
        end
      end
    end

    context 'when the school is a FurtherEducationSchool' do
      let(:school) { build(:fe_school, fe_type: 'sixth_form_college') }

      it 'starts with College' do
        expect(form.chromebook_domain_label).to start_with('College')
      end

      it 'does not include " or "' do
        expect(form.chromebook_domain_label).not_to include(' or ')
      end
    end
  end
end
