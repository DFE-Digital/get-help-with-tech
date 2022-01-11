require 'rails_helper'

RSpec.feature 'Bulk allocation upload' do
  let(:non_support_user) { create(:user) }
  let(:support_user) { create(:support_user) }
  let(:bulk_upload_allocation_page) { PageObjects::Support::Schools::BulkUploadAllocationPage.new }
  let(:allocation_batch_job_page) { PageObjects::Support::AllocationBatchJobs::ShowPage.new }
  let!(:school_a) { create(:school, urn: '123456') }
  let!(:school_b) { create(:school, ukprn: '12345678') }

  before do
    stub_computacenter_outgoing_api_calls
  end

  scenario 'non-support users can´t upload bulk allocations' do
    sign_in_as non_support_user

    visit devices_enable_orders_for_many_schools_support_schools_path
    expect_forbidden_page_to_be_displayed
  end

  scenario 'process all schools but do not notify' do
    sign_in_as support_user

    goto_bulk_upload_allocations
    bulk_upload_allocation_page.choose_file_button.attach_file(Rails.root.join('spec/fixtures/files/allocation_upload_with_positive_deltas.csv'))
    choose('No')
    click_on('Upload allocations')

    expect(allocation_batch_job_page).to be_displayed
    expect(allocation_batch_job_page).to have_id(text: AllocationBatchJob.last.batch_id)
    expect(allocation_batch_job_page).to have_processed_jobs(text: '2 / 2')
    expect(allocation_batch_job_page).to have_aggregate_allocation_change(text: '3')

    expect(allocation_batch_job_page.schools.size).to eq(2)

    school_a_row = allocation_batch_job_page.schools.detect { |row| row.urn.text == school_a.urn.to_s }
    expect(school_a_row.text).to eq('123456 1 1 can_order false false true')
    expect(school_a_row.to_capybara_node['class']).not_to include('govuk-tag--yellow')

    school_b_row = allocation_batch_job_page.schools.detect { |row| row.ukprn.text == school_b.ukprn.to_s }
    expect(school_b_row.text).to eq('12345678 2 2 can_order false false true')
    expect(school_b_row.to_capybara_node['class']).not_to include('govuk-tag--yellow')
  end

  scenario 'ignore unknown schools' do
    sign_in_as support_user

    goto_bulk_upload_allocations
    bulk_upload_allocation_page.choose_file_button.attach_file(Rails.root.join('spec/fixtures/files/allocation_upload_with_unknown_schools.csv'))
    choose('No')
    click_on('Upload allocations')

    expect(allocation_batch_job_page).to be_displayed
    expect(allocation_batch_job_page).to have_id(text: AllocationBatchJob.last.batch_id)
    expect(allocation_batch_job_page).to have_processed_jobs(text: '1 / 1')
    expect(allocation_batch_job_page).to have_aggregate_allocation_change(text: '1')

    expect(allocation_batch_job_page.schools.size).to eq(1)

    school_a_row = allocation_batch_job_page.schools.detect { |row| row.urn.text == school_a.urn.to_s }
    expect(school_a_row.text).to eq('123456 1 1 can_order false false true')
    expect(school_a_row.to_capybara_node['class']).not_to include('govuk-tag--yellow')
  end

  scenario 'school rows with deltas that cannot be set exactly as they come, are highlighted' do
    sign_in_as support_user

    goto_bulk_upload_allocations
    bulk_upload_allocation_page.choose_file_button.attach_file(Rails.root.join('spec/fixtures/files/allocation_upload_with_negative_deltas.csv'))
    choose('No')
    click_on('Upload allocations')

    expect(allocation_batch_job_page).to be_displayed
    expect(allocation_batch_job_page).to have_id(text: AllocationBatchJob.last.batch_id)
    expect(allocation_batch_job_page).to have_processed_jobs(text: '2 / 2')
    expect(allocation_batch_job_page).to have_aggregate_allocation_change(text: '1')

    school_a_row = allocation_batch_job_page.schools.detect { |row| row.urn.text == school_a.urn.to_s }
    expect(school_a_row.text).to eq('123456 1 1 can_order false false true')
    expect(school_a_row.to_capybara_node['class']).not_to include('govuk-tag--yellow')

    school_b_row = allocation_batch_job_page.schools.detect { |row| row.ukprn.text == school_b.ukprn.to_s }
    expect(school_b_row.text).to eq('12345678 -2 0 can_order false false true')
    expect(school_b_row.to_capybara_node['class']).to include('govuk-tag--yellow')
  end

  scenario 'some schools are yet to be processed', sidekiq: false do
    sign_in_as support_user

    goto_bulk_upload_allocations
    bulk_upload_allocation_page.choose_file_button.attach_file(Rails.root.join('spec/fixtures/files/allocation_upload_with_positive_deltas.csv'))
    choose('Yes')
    Sidekiq::Testing.fake! do
      expect {
        click_on('Upload allocations')
      }.to change(AllocationJob.enqueued_jobs, :size).by(2)
    end

    expect(allocation_batch_job_page).to be_displayed
    expect(allocation_batch_job_page).to have_id(text: AllocationBatchJob.last.batch_id)
    expect(allocation_batch_job_page).to have_processed_jobs(text: '0 / 2')
    expect(allocation_batch_job_page).to have_aggregate_allocation_change(text: '0')

    school_a_row = allocation_batch_job_page.schools.detect { |row| row.urn.text == school_a.urn.to_s }
    expect(school_a_row.text).to eq('123456 1 can_order true false false')
    expect(school_a_row.applied_delta.text).to be_blank
    expect(school_a_row.to_capybara_node['class']).to include('govuk-tag--yellow')

    school_b_row = allocation_batch_job_page.schools.detect { |row| row.ukprn.text == school_b.ukprn.to_s }
    expect(school_b_row.text).to eq('12345678 2 can_order true false false')
    expect(school_b_row.applied_delta.text).to be_blank
    expect(school_b_row.to_capybara_node['class']).to include('govuk-tag--yellow')
  end

  scenario 'process all schools and notify' do
    sign_in_as support_user

    goto_bulk_upload_allocations
    bulk_upload_allocation_page.choose_file_button.attach_file(Rails.root.join('spec/fixtures/files/allocation_upload_with_positive_deltas.csv'))
    choose('Yes')
    click_on('Upload allocations')

    expect(allocation_batch_job_page).to be_displayed
    expect(allocation_batch_job_page).to have_id(text: AllocationBatchJob.last.batch_id)
    expect(allocation_batch_job_page).to have_processed_jobs(text: '2 / 2')
    expect(allocation_batch_job_page).to have_aggregate_allocation_change(text: '3')

    school_a_row = allocation_batch_job_page.schools.detect { |row| row.urn.text == school_a.urn.to_s }
    expect(school_a_row.text).to eq('123456 1 1 can_order true true true')
    expect(school_a_row.to_capybara_node['class']).not_to include('govuk-tag--yellow')

    school_b_row = allocation_batch_job_page.schools.detect { |row| row.ukprn.text == school_b.ukprn.to_s }
    expect(school_b_row.text).to eq('12345678 2 2 can_order true true true')
    expect(school_b_row.to_capybara_node['class']).not_to include('govuk-tag--yellow')
  end

private

  def expect_forbidden_page_to_be_displayed
    expect(page).to have_content('Forbidden')
    expect(page).to have_content('You’re not allowed to do that.')
  end

  def goto_bulk_upload_allocations
    visit devices_enable_orders_for_many_schools_support_schools_path
    expect(bulk_upload_allocation_page).to be_displayed
    expect(bulk_upload_allocation_page).to have_header(text: 'Bulk upload allocation updates')
    expect(bulk_upload_allocation_page).to have_choose_file_button
    expect(bulk_upload_allocation_page).to have_send_notifications_yes_label(text: 'Yes')
    expect(bulk_upload_allocation_page).to have_send_notifications_no_label(text: 'No')
    expect(bulk_upload_allocation_page).to have_submit_button(text: 'Upload allocations')
  end
end
