require 'rails_helper'

RSpec.describe NavComponent do
  let(:user) { build(:local_authority_user) }
  let(:current_path) { '/current/path' }
  let(:test_context) { ActionView::LookupContext.new(ActionController::Base.view_paths) }
  let(:test_view) { ActionView::Base.new(test_context, {}, ActionController::Base.new) }

  subject(:nav) { NavComponent.new(current_path: current_path, user: user) }

  describe '#class_name' do
    it 'includes govuk-header__navigation-item' do
      expect(nav.class_name(current_path)).to match(/govuk-header__navigation-item[\s$]/)
    end

    context 'when the given url is the current_path' do
      it 'includes govuk-header__navigation-item--active' do
        expect(nav.class_name(current_path)).to include('govuk-header__navigation-item--active')
      end
    end
  end

  describe '#nav_item' do
    it 'returns the given content in an li tag' do
      expect(nav.nav_item(content: 'given content')).to match(/<li[^>]*>given content<\/li>/)
    end

    it 'gives the li a class of class_name' do
      expect(nav.nav_item(content: 'given content', url: 'given url')).to match(/<li class="govuk-header__navigation-item"/)
    end
  end

  describe '#render_nav_link' do
    let(:link) { NavLinkComponent.new(title: 'link content', url: 'some url') }

    it 'wraps the rendered link in a nav_item' do
      expect(nav.render_nav_link(link, test_view)).to eq('<li class="govuk-header__navigation-item"><a class="govuk-header__link" href="some url">link content</a></li>')
    end
  end

  describe '#render_nav_links' do
    let(:link_1) { NavLinkComponent.new(title: 'content 1', url: 'some url 1') }
    let(:link_2) { NavLinkComponent.new(title: 'content 2', url: 'some url 2') }
    let(:link_1_expected_html) do
      <<~HTML
        <li class="govuk-header__navigation-item"><a class="govuk-header__link" href="some url 1">content 1</a></li>
      HTML
    end
    let(:link_2_expected_html) do
      <<~HTML
        <li class="govuk-header__navigation-item"><a class="govuk-header__link" href="some url 2">content 2</a></li>
      HTML
    end

    it 'renders each given link' do
      output = nav.render_nav_links([link_1, link_2], test_view)
      expect(output).to include(link_1_expected_html.strip)
      expect(output).to include(link_1_expected_html.strip)
    end
  end
end
