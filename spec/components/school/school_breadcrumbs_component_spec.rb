require 'rails_helper'

RSpec.describe School::SchoolBreadcrumbsComponent do
  include Rails.application.routes.url_helpers

  let(:local_authority) { create(:local_authority) }
  let(:single_academy_trust) { create(:trust, :single_academy_trust) }
  let(:school) { create(:school, :la_maintained, responsible_body: local_authority) }
  let(:academy) { create(:school, :academy, responsible_body: single_academy_trust) }
  let(:items) { 'a title' }

  subject(:result) { render_inline(described_class.new(school:, user:, items:)) }

  def has_link_to?(doc:, text:)
    doc.css('a').map(&:text).include?(text)
  end

  context 'when the user has no responsible_body' do
    let(:user) { create(:user, responsible_body: nil) }

    context 'and one school which is not a single_academy_trust' do
      before do
        user.schools << school
      end

      it 'does not have a link to Your schools or Your organisations' do
        expect(has_link_to?(doc: result, text: 'Your schools')).to be_falsey
        expect(has_link_to?(doc: result, text: 'Your organisations')).to be_falsey
      end

      it 'has a link to Home, pointing to that school' do
        expect(has_link_to?(doc: result, text: 'Home')).to be_truthy
        expect(result.css(:a, href: home_school_path(school))).to be_truthy
      end
    end

    context 'and multiple schools' do
      before do
        user.schools << school
        user.schools << academy
      end

      it 'has a link to Your schools' do
        expect(has_link_to?(doc: result, text: 'Your schools')).to be_truthy
      end
    end
  end

  context 'when the user has a responsible_body' do
    let(:user) { create(:user, responsible_body: local_authority) }

    context 'and is a single_academy_trust user' do
      let(:user) { create(:single_academy_trust_user, responsible_body: single_academy_trust, schools: [academy]) }

      it 'does not have a link to Your schools or Your organisations' do
        expect(has_link_to?(doc: result, text: 'Your schools')).to be_falsey
        expect(has_link_to?(doc: result, text: 'Your organisations')).to be_falsey
      end

      it 'has a link to Home, pointing to that school' do
        expect(has_link_to?(doc: result, text: 'Home')).to be_truthy
        expect(result.css(:a, href: home_school_path(academy))).to be_truthy
      end
    end

    context 'and one school which is not a single_academy_trust' do
      before do
        user.schools << school
      end

      it 'does not have a link to Your schools' do
        expect(has_link_to?(doc: result, text: 'Your schools')).to be_falsey
      end

      it 'has a link to Your organisations' do
        expect(has_link_to?(doc: result, text: 'Your organisations')).to be_truthy
      end

      it 'has a link to that school' do
        expect(has_link_to?(doc: result, text: school.name)).to be_truthy
      end
    end
  end
end
