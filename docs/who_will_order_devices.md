# Who will order devices

DfE policy allocates a certain number of devices (laptops and routers) to each school in the GHwT programme.

For children to obtain and benefit from the use of those devices, some authorized users (either school users or a user from the school's responsible body) need to order those devices via the supplier's portal.
Currently Computacenter's TechSource website.

What users are authorized to place devices orders for a given school?

Each school has a field (`who_will_order_devices`) to save the organisation (either `school` or `responsible_body`) responsible for orders and device management for that school.
This field can only be populated with one of those two values or leave it unset. 

When no value is set (value remains `nil`), the organization responsible for managing devices for that school is determined by the Responsible Body (RB) that school is associated to.

RBs set a default value for these schools on their field `default_who_will_order_devices_for_schools`. Similarly to `School#who_will_order_devices`, this field can only store `school` or `responsible_body` as possible values.

Therefore, the authorised users able to place orders for the devices allocated to a school are:

- Those from the organization set by the school.
- In case no value is set by the school, the default value set by the responsible body will apply.
- Also, it is technically possible to have both fields unset, (meaning `a decision is yet to be made`) though none of the schools currently (Dec 2021) in the programme are left unset like that.

When a school is directly 
```
school.who_will_order_devices == 'school'
```

or indirectly 

```
school.who_will_order_devices == nil
school.rb.default_who_will_order_devices_for_schools == 'school'
```

set to order devices, we say it ‘_manages devices_’.

When a responsible body sets `school` as the default value to order school devices

```
rb.default_who_will_order_devices_for_schools == ‘school’
```
we say it '_devolves devices management_' to schools.


Similarly, when a school is directly
```
school.who_will_order_devices == 'responsible_body'
```

or indirectly

```
school.who_will_order_devices == nil
school.rb.default_who_will_order_devices_for_schools == 'responsible_body'
```

set to leave devices management to its rb, we say it is _‘centrally managed’_.

When a responsible body sets `responsible_body` as the default value to order school devices, 

```
rb.default_who_will_order_devices_for_schools == ‘responsible_body’
```
we say it _‘centrally manages schools’_.


## How devices are managed
Schools are usually managed individually either by themselves or their associated rb.

For schools centrally managed, a responsible body may decide to do it individually (placing specific orders for each of them) or collectively, setting a virtual cap pool.

These responsible bodies needs the ability to have devices sent to a central location rather than directly to individual schools. Typically this was to facilitate the installation, configuration and distribution of the devices from a centralised IT office.

A virtual cap pool allows a responsible body to group together laptop and/or router allocations of the schools they centrally manage so the full amount is available to be ordered for, and therefore delivered to, any of the organisation's schools.
