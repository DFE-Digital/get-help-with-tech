require 'rails_helper'

describe Support::Gias::SchoolDetailsComponent do
  include Rails.application.routes.url_helpers

  let(:support_user) { build(:support_user, :third_line) }
  let(:staged_school) { create(:staged_school, :primary) }

  subject(:result) { render_inline(described_class.new(school: staged_school, viewer: support_user)) }

  it 'displays the school details' do
    expect(value_for_row(result, 'URN').text).to include(staged_school.urn.to_s)
    expect(value_for_row(result, 'Setting').text).to include(staged_school.human_for_school_type)
    staged_school.address_components.each do |address_part|
      expect(value_for_row(result, 'Address').text).to include(address_part)
    end
  end

  context 'when the staged school needs to be opened' do
    context 'when there is a predecessor school' do
      let(:staged_school_to_close) { create(:staged_school, :primary) }
      let(:school_link) { create(:staged_school_link, :predecessor, staged_school: staged_school, link_urn: staged_school_to_close.urn) }
      let(:school) { create(:school, urn: staged_school_to_close.urn) }

      before do
        school_link
        school
      end

      it 'displays a link to the predecessor school' do
        expect(value_for_row(result, 'Predecessor').text).to include("#{school.name} (#{school.urn})")
        expect(action_for_row(result, 'Predecessor').text).to include('View')
        expect(action_for_row(result, 'Predecessor').css('a')[0][:href]).to include(support_school_path(urn: school.urn))
      end
    end
  end

  context 'when the staged school needs to be closed' do
    let(:staged_school) { create(:staged_school, :primary, status: 'closed') }

    context 'when there is a successor school to be added' do
      let(:staged_school_to_open) { create(:staged_school, :primary) }
      let(:school_link) { create(:staged_school_link, :successor, staged_school: staged_school, link_urn: staged_school_to_open.urn) }

      before do
        school_link
      end

      it 'displays a link to the successor staged school' do
        expect(value_for_row(result, 'Successor').text).to include("#{staged_school_to_open.urn} (waiting to be added)")
        expect(action_for_row(result, 'Successor').text).to include('View')
        expect(action_for_row(result, 'Successor').css('a')[0][:href]).to include(support_gias_schools_to_add_path(urn: staged_school_to_open.urn))
      end
    end

    context 'when there is a successor school that has already been added' do
      let(:staged_school_to_open) { create(:staged_school, :primary) }
      let(:school_link) { create(:staged_school_link, :successor, staged_school: staged_school, link_urn: staged_school_to_open.urn) }
      let(:school) { create(:school, urn: staged_school_to_open.urn, name: staged_school_to_open.name) }

      before do
        school_link
        school
      end

      it 'displays a link to the successor school' do
        expect(value_for_row(result, 'Successor').text).to include("#{school.name} (#{school.urn})")
        expect(action_for_row(result, 'Successor').text).to include('View')
        expect(action_for_row(result, 'Successor').css('a')[0][:href]).to include(support_school_path(urn: school.urn))
      end
    end
  end
end
