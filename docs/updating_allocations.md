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

```ruby
School.where(order_state: :can_order, status: :open).sum(:raw_laptop_cap) - School.where(order_state: :can_order, status: :open).sum(:raw_laptops_ordered) # for computers
School.where(order_state: :can_order, status: :open).sum(:raw_router_cap) - School.where(order_state: :can_order, status: :open).sum(:raw_routers_ordered) # for routers (coms_device isn't a typo)
```

Generating the comprehensive "all allocations" report is described in more detail at `docs/reporting_allocations.md`.

## Virtual Cap documentation

Cap documentation is at `https://github.com/DFE-Digital/get-help-with-tech/blob/main/docs/virtual_cap_pools.md`

## Changing the cap/allocation for an individual school

Devices are sold to responsible bodies but shipped to schools (legal owners).

We change the cap/allocation on our service then inform Computacenter of the new cap
(Computacenter don't need to know the allocation numbers).

To get into the production console:

`make prod ssh`

In the console, grab the school first, then something like:

```ruby
UpdateSchoolDevicesService.new(school: school, laptop_cap: 10, laptop_allocation: 10).call
UpdateSchoolDevicesService.new(school: school, router_cap: 10, router_allocation: 10).call
UpdateSchoolDevicesService.new(school: school, order_state: :can_order).call
```

This will send out e-mails reflecting the change. 

## Changing the cap/allocation for multiple schools

When changing the numbers for a large number of schools at once (as is the usual
case), it takes time for Computacenter to process such a large change. Instead it's
preferable to change the numbers within our app and wait for Computacenter to let us 
know that all the numbers have been changed within their system, before communicating to
our app's users that they can begin to make orders which are within the new caps
and allocations.

To avoid large numbers of e-mails being sent, you can run a modified version of
the update method called above.

For changes to multiple schools, the approach is to copy the data from the spreadsheet
then get it into a Ruby data structure to iterate over in the console.

## Generating reports

A school's URN acts as its ID.

At `http://localhost:3000/support/schools/results` (but host updated to production 
environment), paste in URNs then click `Download allocations as CSV` to get a CSV file. 

### Working with allocations from within the Web app

https://github.com/DFE-Digital/get-help-with-tech/pull/1540 describes a merged pull request which
shows how to work with allocations from the Web interface. This removes the need to paste code into
the console and modify it manually to not send notifications to service users until a later time (when
Computacenter have manually acknowledged their system is up-to-date with the latest allocations
and caps, and thus new orders will succeed).

### Export 'All Allocations' via the production console

(This is no longer necessary given the Web interface provided above but seeing the code might be
useful to new starters.)

From your terminal:

```make prod ssh```

Once connected, start the rails console:

```bundle exec rails c```

Export all allocations to CSV using the AllocationsExporter from app/services/allocations_exporter.rb:

```AllocationsExporter.new('/tmp/all_allocations.csv').export```

Exit the rails console and the ssh session if you are done with them.

Use ```make <env> download``` to download the exported CSV:

```make prod download LOCAL_PATH=/tmp/GHWT REMOTE_PATH=/tmp/all_allocations.csv```

#### Example export of a subset of allocations

First build the list of schools that represent the subset:

```
schools = School.has_not_fully_ordered_laptops.where(type: 'FurtherEducationSchool')
```

Pass the collection of schools to the export method of the AllocationsExporter:

```AllocationsExporter.new("/tmp/fe_unused_allocations.csv").export(schools)```
