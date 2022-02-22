require 'rails_helper'

RSpec.describe ChromebookInformationForm do
  let(:will_need_chromebooks) { 'yes' }
  let(:recovery_email_address) { 'ab@c.com' }
  let(:school_or_rb_domain) { 'school.sch.uk' }
  let(:school) do
    instance_double(CompulsorySchool,
                    institution_type: 'Educational foundation',
                    la_funded_provision?: false)
  end
  let(:form) do
    described_class.new(school:,
                        will_need_chromebooks:,
                        recovery_email_address:,
                        school_or_rb_domain:)
  end

  let!(:request) do
    stub_request(:get, 'https://www.google.com/a/school.sch.uk/ServiceLogin')
      .to_return(status: 200, body: '', headers: {})
  end

  context 'when the email address has whitespace' do
    let(:recovery_email_address) { ' ab@c.com ' }

    it 'is valid' do
      form.validate
      expect(form.errors[:recovery_email_address]).to be_blank
    end

    it 'strips the whitespace' do
      form.validate
      expect(form.recovery_email_address).to eq('ab@c.com')
    end
  end

  context 'when the school_or_rb_domain has whitespace' do
    let(:school_or_rb_domain) { ' school.sch.uk ' }

    it 'validates the corrected domain against Google' do
      form.validate
      expect(request).to have_been_made
    end

    it 'strips the whitespace' do
      expect(form.school_or_rb_domain).to eql('school.sch.uk')
    end
  end

  context 'when :will_need_chromebooks is blank' do
    let(:will_need_chromebooks) { nil }

    it 'is not valid' do
      expect(form.valid?).to be_falsey
    end

    it 'has an error message including the schools institution_type' do
      form.validate
      expect(form.errors[:will_need_chromebooks]).to include('Tell us whether the Educational foundation will need Chromebooks')
    end
  end

  context 'LA school' do
    let(:school) { create(:iss_provision) }

    let(:form) do
      described_class.new(school:,
                          will_need_chromebooks:,
                          will_need_chromebooks_message: 'Tell us if pupils will need Chromebooks')
    end

    context 'when :will_need_chromebooks is blank' do
      let(:will_need_chromebooks) { nil }

      it 'is not valid' do
        expect(form.valid?).to be_falsey
      end

      it 'has an error message including the schools institution_type' do
        form.validate
        expect(form.errors[:will_need_chromebooks]).to include('Tell us if pupils will need Chromebooks')
      end
    end
  end
end
