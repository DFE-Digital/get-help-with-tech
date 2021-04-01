# Updating allocations

## Triggers

* If there's a future COVID-19 lockdown
* Policy changes (for example, increasing all school allocations by 10%)

## Order to change allocations comes from

* Anya Kemble (Lead Policy Designer)
* Alana Afflick's allocating team
* Pritesh Patel (Product Manager)

Typically this is a task which only occurs once every few months. 
Data will typically be in the form of a spreadsheet.
When decreasing numbers, the cap can't exceed the allocation (validated by model).

## Queries

The team might be asked how many devices we have unallocated (typically computers rather than routers).

`SchoolDeviceAllocation.by_device_type(:std_device).includes(:school).where(schools: {order_state: :can_order, status: :open}).sum(:cap) - SchoolDeviceAllocation.by_device_type(:std_device).includes(:school).where(schools: {order_state: :can_order, status: :open}).sum(:devices_ordered)`

## Relevant code

* `school_device_allocation.rb`
* `allocation_updater.rb`
* `school_order_state_and_cap_update_service.rb`
* `school_can_order_devices_notifications.rb`
* `cap_change_notifier.rb`
* `cap_update_request.rb`
* `cap_update_request.xml.builder`
* `allocations_exporter.rb`

Cap documentation diagram is at `https://github.com/DFE-Digital/get-help-with-tech/blob/main/docs/virtual_cap_pools.md`

## Changing the cap/allocation for an individual school

Devices are sold to responsible bodies but shipped to schools (legal owners).

We change the cap/allocation on our service then inform Computacenter of the new cap
(Computacenter don't need to know the allocation numbers).

To get into the production console:

`make prod ssh`

In the console, grab the school first, then:

`school.std_device_allocation.update(cap: 10, allocation: 10)`
`SchoolOrderStateAndCapUpdateService.new(school: school, order_state: :can_order).update!`

The last line above will send out e-mails reflecting the change. 

## Changing the cap/allocation for multiple schools

To avoid large numbers of e-mails being sent, you might want to use a modified version of
the update method above to ensure e-mails aren't sent.

For changes to multiple schools, the approach is to copy the data from the spreadsheet
then get it into some Ruby data structure to iterate over in the console.

## Generating reports

A school's URN acts as its ID.

At `http://localhost:3000/support/schools/results` (but host updated to production 
environment), paste in URNs then click `Download allocations as CSV` to get a CSV file. 

There's also a make command to download it securely: `make download ssh` (not sure what needs to be done here).