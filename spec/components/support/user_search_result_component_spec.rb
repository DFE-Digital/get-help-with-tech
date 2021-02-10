require 'rails_helper'

RSpec.describe Support::UserSearchResultComponent do
  include Rails.application.routes.url_helpers

  let(:st_marys) { create(:school, name: 'St Mary’s School') }
  let(:st_josephs) { create(:school, name: 'St Joseph’s School') }
  let(:coventry) { create(:local_authority, name: 'Coventry') }
  let(:user) { create(:user, schools: [st_marys, st_josephs], responsible_body: coventry, email_address: 'jsmith@school.sch.uk') }
  let(:unassociated_user) { create(:user, responsible_body: nil, schools: [], email_address: 'fran@free.com', full_name: 'Fran Free') }
  let(:support_user) { create(:support_user) }

  subject { described_class.new(user: user, current_user: support_user) }

  it 'renders a link to the user’s support page' do
    expect(rendered_result_html).to include(support_user_path(user))
  end

  it 'renders the user’s email address' do
    expect(rendered_result_text).to include('jsmith@school.sch.uk')
  end

  it 'renders links to the responsible body support page' do
    expect(rendered_result_html).to include(support_responsible_body_path(coventry))
  end

  it 'renders links to the school support pages' do
    expect(rendered_result_html).to include(support_school_path(urn: st_marys.urn))
    expect(rendered_result_html).to include(support_school_path(urn: st_josephs.urn))
  end

  context 'when the user has no associations' do
    subject { described_class.new(user: unassociated_user, current_user: support_user) }

    it 'shows (no schools or responsible bodies) in the associations' do
      expect(rendered_result_html).to include('No responsible bodies, schools, colleges or FE institutions')
    end
  end

  def rendered_result_html
    render_inline(subject).to_html
  end

  def rendered_result_text
    render_inline(subject).text
  end
end
