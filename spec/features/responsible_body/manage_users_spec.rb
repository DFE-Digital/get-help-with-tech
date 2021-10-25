require 'rails_helper'

RSpec.feature 'Managing ResponsibleBody users' do
  let!(:rb_user) { create(:local_authority_user, full_name: 'AAA Smith') }
  let!(:rb_user_2) { create(:local_authority_user, full_name: 'ZZZ Jones', responsible_body: rb_user.responsible_body) }
  let!(:rb_user_3_deleted) { create(:local_authority_user, :deleted, full_name: 'John Doe', responsible_body: rb_user.responsible_body) }
  let(:user_from_other_rb) { create(:trust_user) }
  let(:rb_users_index_page) { PageObjects::ResponsibleBody::UsersPage.new }
  let(:new_rb_user_form) { PageObjects::ResponsibleBody::NewUserPage.new }

  before do
    create(:school, laptops: [2, 2, 1], responsible_body: rb_user.responsible_body)

    sign_in_as rb_user
  end

  it 'shows the list of our users' do
    click_on 'Manage users'
    expect(rb_users_index_page).to be_displayed
    expect(page).to have_content 'Manage users'
  end

  it 'shows the name and attributes for each user in this RB' do
    click_on 'Manage users'
    expect(rb_users_index_page.user_rows.size).to eq(2)
    expect(rb_users_index_page.user_rows[0]).to have_content(rb_user.full_name)
    expect(rb_users_index_page.user_rows[1]).to have_content(rb_user_2.full_name)

    expect(rb_users_index_page).not_to have_content(rb_user_3_deleted.full_name)
  end

  it 'shows a link to Invite a new user' do
    click_on 'Manage users'
    expect(page).to have_content 'Invite a new user'
  end

  context 'clicking "Invite a new user"' do
    before do
      click_on 'Manage users'
      click_on 'Invite a new user'
    end

    it 'shows the new user form' do
      expect(new_rb_user_form).to be_displayed
      expect(page).to have_field 'Name'
      expect(page).to have_field 'Email address'
      expect(page).to have_field 'Telephone number'
    end

    it 'shows an error when I submit the form with missing fields' do
      click_on('Send invite')
      expect(page).to have_content('There is a problem')
      expect(page).to have_http_status(:unprocessable_entity)
    end

    it 'adds the user when I submit the form with all required fields' do
      fill_in('Name', with: 'ZZZ New RB User')
      fill_in('Email address', with: 'new.user@rb.example.com')
      fill_in('Telephone number', with: '01234 567890')
      click_on('Send invite')

      expect(rb_users_index_page).to be_displayed
      expect(rb_users_index_page.user_rows[2]).to have_content('ZZZ New RB User')
    end
  end

  it 'does not include any users from any other responsible_body' do
    click_on 'Manage users'
    expect(page).not_to have_content(user_from_other_rb.full_name)
  end

  context 'clicking "Edit user"' do
    before do
      click_on 'Manage users'
      within(rb_users_index_page.user_rows[0]) do
        click_on 'Edit user'
      end
    end

    it 'shows the edit user form' do
      expect(page).to have_content 'Edit user'
      expect(page).to have_field 'Name'
      expect(page).to have_field 'Email address'
      expect(page).to have_field 'Telephone number'
      expect(page).to have_button 'Save changes'
    end

    it 'shows an error when I submit the form with missing fields' do
      fill_in('Name', with: '')
      click_on('Save changes')
      expect(page).to have_content('There is a problem')
      expect(page).to have_http_status(:unprocessable_entity)
    end

    it 'update the user when I submit the form with all required fields' do
      fill_in('Name', with: 'ZZZ New RB User')
      fill_in('Email address', with: 'new.user@rb.example.com')
      fill_in('Telephone number', with: '01234 567890')
      click_on('Save changes')

      expect(rb_users_index_page).to be_displayed
      expect(rb_users_index_page.user_rows[1]).to have_content('ZZZ New RB User')
    end
  end
end
