require 'rails_helper'

RSpec.feature 'Bulk allocation upload', skip: true do
  let(:non_support_user) { create(:user) }
  let(:support_user) { create(:support_user) }
  let(:negative_deltas_file) { Rails.root.join('spec/fixtures/files/allocation_upload_with_negative_deltas.csv') }
  let(:positive_deltas_file) { Rails.root.join('spec/fixtures/files/allocation_upload_with_positive_deltas.csv') }
  let(:unknown_schools_file) { Rails.root.join('spec/fixtures/files/allocation_upload_with_unknown_schools.csv') }
  let(:bulk_upload_allocation_page) { PageObjects::Support::Schools::BulkUploadAllocationPage.new }
  let(:allocation_batch_job_page) { PageObjects::Support::AllocationBatchJobs::ShowPage.new }
  let(:school_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:rb) { create(:trust, :vcap, :manages_centrally) }
  let!(:school_a) { create(:school, :centrally_managed, responsible_body: rb, urn: '123456', name: 'SchoolA') }
  let!(:school_b) { create(:school, ukprn: '12345678', name: 'SchoolB') }

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

    goto_bulk_upload_allocations(positive_deltas_file)
    bulk_upload_allocation_page.choose_file_button.attach_file(positive_deltas_file)
    choose('No')
    click_on('Upload allocations')

    expect_processing_details(batch_id: AllocationBatchJob.last.batch_id,
                              processed_jobs: 2,
                              total_jobs: 2,
                              aggregate_allocation_change: 3)

    expect_row_for_school(urn: school_a.urn, text: '123456 1 1 can_order false false true', highlighted: false)
    expect_row_for_school(ukprn: school_b.ukprn, text: '12345678 2 2 can_order false false true', highlighted: false)
    expect_new_allocation_for_school(identifier: '123456', name: 'SchoolA', allocation: '1 device')
    expect_new_allocation_for_school(identifier: '12345678', name: 'SchoolB', allocation: '2 devices')
  end

  scenario 'ignore unknown schools' do
    sign_in_as support_user

    goto_bulk_upload_allocations(unknown_schools_file)
    bulk_upload_allocation_page.choose_file_button.attach_file(unknown_schools_file)
    choose('No')
    click_on('Upload allocations')

    expect_processing_details(batch_id: AllocationBatchJob.last.batch_id,
                              processed_jobs: 1,
                              total_jobs: 1,
                              aggregate_allocation_change: 1)

    expect_row_for_school(urn: school_a.urn, text: '123456 1 1 can_order false false true', highlighted: false)
    expect_new_allocation_for_school(identifier: '123456', name: 'SchoolA', allocation: '1 device')
  end

  scenario 'school rows with deltas that cannot be set exactly as they are provided, are highlighted' do
    sign_in_as support_user

    goto_bulk_upload_allocations(negative_deltas_file)
    bulk_upload_allocation_page.choose_file_button.attach_file(negative_deltas_file)
    choose('No')
    click_on('Upload allocations')

    expect_processing_details(batch_id: AllocationBatchJob.last.batch_id,
                              processed_jobs: 2,
                              total_jobs: 2,
                              aggregate_allocation_change: 1)

    expect_row_for_school(urn: school_a.urn, text: '123456 1 1 can_order false false true', highlighted: false)
    expect_row_for_school(ukprn: school_b.ukprn, text: '12345678 -2 0 can_order false false true', highlighted: true)
    expect_new_allocation_for_school(identifier: '123456', name: 'SchoolA', allocation: '1 device')
    expect_new_allocation_for_school(identifier: '12345678', name: 'SchoolB', allocation: '0 devices')
  end

  scenario 'process all schools and notify' do
    sign_in_as support_user

    goto_bulk_upload_allocations(positive_deltas_file)
    bulk_upload_allocation_page.choose_file_button.attach_file(positive_deltas_file)
    choose('Yes')
    click_on('Upload allocations')

    expect_processing_details(batch_id: AllocationBatchJob.last.batch_id,
                              processed_jobs: 2,
                              total_jobs: 2,
                              aggregate_allocation_change: 3)

    expect_row_for_school(urn: school_a.urn, text: '123456 1 1 can_order true true true', highlighted: false)
    expect_row_for_school(ukprn: school_b.ukprn, text: '12345678 2 2 can_order true true true', highlighted: false)
    expect_new_allocation_for_school(identifier: '123456', name: 'SchoolA', allocation: '1 device')
    expect_new_allocation_for_school(identifier: '12345678', name: 'SchoolB', allocation: '2 devices')
  end

private

  def expect_forbidden_page_to_be_displayed
    expect(page).to have_content('Forbidden')
    expect(page).to have_content('You’re not allowed to do that.')
  end

  def expect_processing_details(batch_id:, processed_jobs:, total_jobs:, aggregate_allocation_change:)
    expect(allocation_batch_job_page).to be_displayed
    expect(allocation_batch_job_page).to have_id(text: batch_id.to_s)
    expect(allocation_batch_job_page).to have_processed_jobs(text: [processed_jobs, total_jobs].join(' / '))
    expect(allocation_batch_job_page).to have_aggregate_allocation_change(text: aggregate_allocation_change.to_s)
    expect(allocation_batch_job_page.schools.size).to eq(total_jobs)
  end

  def expect_row_for_school(text:, highlighted:, **opts)
    school_row = school_row(**opts)
    expect(school_row.text).to eq(text)
    expect(school_row.to_capybara_node['class'].include?('govuk-tag--yellow')).to eq(highlighted)
  end

  def expect_new_allocation_for_school(allocation:, identifier:, name:)
    school_page.load(urn: identifier)
    expect(school_page).to have_text(name)
    expect(school_page.school_details['Device allocation'].value).to eq(allocation)
  end

  def goto_bulk_upload_allocations(file)
    stub_file_storage(file)
    visit devices_enable_orders_for_many_schools_support_schools_path
    expect(bulk_upload_allocation_page).to be_displayed
    expect(bulk_upload_allocation_page).to have_header(text: 'Bulk allocation updates')
    expect(bulk_upload_allocation_page).to have_choose_file_button
    expect(bulk_upload_allocation_page).to have_send_notifications_yes_label(text: 'Yes')
    expect(bulk_upload_allocation_page).to have_send_notifications_no_label(text: 'No')
    expect(bulk_upload_allocation_page).to have_submit_button(text: 'Upload allocations')
  end

  def school_row(**opts)
    allocation_batch_job_page.schools.detect do |row|
      row.send(opts.keys.first).text == opts.values.first.to_s
    end
  end
end
