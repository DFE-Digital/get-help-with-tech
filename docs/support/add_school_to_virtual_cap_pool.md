## Add a school to a virtual cap pool manually

#### Prerequisites

__School__ must:

* be centrally managed

```ruby
school.preorder_information.responsible_body_will_order_devices?
=> true
```

* have a std device allocation or a coms device allocation (best to ensure there are both as it will be more difficult to add a  missing one later)
* not already be in one or more of the responsible body's virtual pools!

__Responsible body__ must:

* Have the `vcap_feature_flag` set to `true`



Schools are normally automatically added to a virtual pool when they are enabled for ordering and the above prerequisites are in place.  This takes place via the `SchoolOrderStateAndCapUpdateService#update!` call used to change the school's order state.

Sometimes it may be necessary to add schools to a pool that are not able to currently order.

1. Ensure the prerequisites above are in place
2. Add the school to the responsible body's virtual pools

```ruby
rb.add_school_to_virtual_cap_pools!(school)
```

This will add the school's device allocations to the appropriate virtual pools

Check that the school's preorder status looks correct,  it may be necessary to force the preorder status to refresh:

```ruby
school.preorder_information.refresh_status!
```

Check that the virtual pool information looks correct, if necessary force a recalculation:

```ruby
rb.calculate_virtual_caps!
=> [#<VirtualCapPool:0x0000564a34d8fef8
  id: 974,
  device_type: "coms_device",
  responsible_body_id: 2777,
  cap: 0,
  devices_ordered: 0,
  created_at: Tue, 24 Nov 2020 11:33:01.114249000 GMT +00:00,
  updated_at: Thu, 07 Jan 2021 13:28:20.375824000 GMT +00:00,
  allocation: 0>,
 #<VirtualCapPool:0x0000564a34d8fc50
  id: 975,
  device_type: "std_device",
  responsible_body_id: 2777,
  cap: 1172,
  devices_ordered: 1207,
  created_at: Tue, 24 Nov 2020 11:33:01.155062000 GMT +00:00,
  updated_at: Thu, 07 Jan 2021 13:28:20.432806000 GMT +00:00,
  allocation: 1213>]
```

You can also verify that a cap update has been sent to Computacenter for the school from the `cap_update_request_timestamp`

```ruby
school.std_device_allocation
=> #<SchoolDeviceAllocation:0x0000564a36cdd670
 id: 20915,
 school_id: 20979,
 device_type: "std_device",
 allocation: 74,
 devices_ordered: 15,
 created_at: Thu, 27 Aug 2020 13:03:26.814923000 BST +01:00,
 updated_at: Thu, 07 Jan 2021 13:28:20.807274000 GMT +00:00,
 last_updated_by_user_id: nil,
 created_by_user_id: nil,
 cap: 74,
 cap_update_request_timestamp: Thu, 07 Jan 2021 13:28:20.440683000 GMT +00:00,
 cap_update_request_payload_id: "2173f28f-c6be-4a46-87ff-d29de6033a9d">
```



