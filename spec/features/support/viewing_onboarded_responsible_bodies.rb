require 'rails_helper'

RSpec.feature 'Viewing on-boarded responsible bodies in the support area', type: :feature do
  let(:responsible_bodies_page) { PageObjects::Support::ResponsibleBodiesPage.new }

  scenario 'DfE users see the on-boarded responsible bodies and stats about them' do
    given_there_are_responsible_bodies_that_have_users
    and_given_there_are_responsible_bodies_that_do_not_have_any_users

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_support_responsible_bodies_page

    then_i_can_see_the_responsible_bodies_with_users
    and_i_cannot_see_the_responsible_bodies_without_users
  end

  def given_there_are_responsible_bodies_that_have_users
    la = create(:local_authority, name: 'Coventry')
    create_list(:user, 2, responsible_body: la)

    trust = create(:trust, name: 'AWESOME TRUST')
    create(:user, responsible_body: trust)
  end

  def and_given_there_are_responsible_bodies_that_do_not_have_any_users
    create(:local_authority, name: 'Wandsworth')
    create(:trust, name: 'ANOTHER TRUST')
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def and_i_visit_the_support_responsible_bodies_page
    responsible_bodies_page.load
  end

  def then_i_can_see_the_responsible_bodies_with_users
    expect(responsible_bodies_page.responsible_body_rows.size).to eq(2)
    expect(responsible_bodies_page.responsible_body_rows[0]).to have_text('AWESOME TRUST')
    expect(responsible_bodies_page.responsible_body_rows[1]).to have_text('Coventry')
  end

  def and_i_cannot_see_the_responsible_bodies_without_users
    expect(page).not_to have_text('Wandsworth')
    expect(page).not_to have_text('ANOTHER TRUST')
  end
end
