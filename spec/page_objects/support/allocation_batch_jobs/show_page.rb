module PageObjects
  module Support
    module AllocationBatchJobs
      class SchoolRow < SitePrism::Section
        element :urn, 'td:nth-of-type(1)'
        element :ukprn, 'td:nth-of-type(2)'
        element :allocation_delta, 'td:nth-of-type(3)'
        element :applied_delta, 'td:nth-of-type(4)'
        element :order_state, 'td:nth-of-type(5)'
        element :send_notification, 'td:nth-of-type(6)'
        element :sent_notification, 'td:nth-of-type(7)'
      end

      class ShowPage < PageObjects::BasePage
        set_url '/support/allocation-batch-jobs{/id}'

        element :id_label, 'table#details tbody tr:nth-of-type(1) th.govuk-table__header'
        element :id, 'table#details tbody tr:nth-of-type(1) td.govuk-table__cell'
        element :processed_jobs_label, 'table#details tbody tr:nth-of-type(2) th.govuk-table__header'
        element :processed_jobs, 'table#details tbody tr:nth-of-type(2) td.govuk-table__cell'
        element :aggregate_allocation_change_label, 'table#details tbody tr:nth-of-type(3) th.govuk-table__header'
        element :aggregate_allocation_change, 'table#details tbody tr:nth-of-type(3) td.govuk-table__cell'

        sections :schools, SchoolRow, 'table#schools tbody tr'
      end
    end
  end
end
