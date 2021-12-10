# Virtual Cap Pools

## Overview

As described on [Who Will Order Devices](./who_will_order_devices.md) Virtual Cap Pools or simply vcaps, are a way for responsible bodies centrally managing some schools to be able to put all their allocated devices in a single pool so that any school can put orders for the whole amount of devices shared.

Usually devices get delivered to one of the schools. Once there, they are configured and distributed to the rest of the schools in the pool.


## Automatically adding schools

Schools are normally automatically added to a virtual pool when they set to be centrally managed by their responsible body and it has a vcap enabled.


## Allocation numbers for Virtual Cap Pools

Conceptually, given that centrally managed schools in a vcap share their devices allocated with the rest of schools in the pool, we can talk about three different components on a vcap:

- **Allocation**: sum of the devices assigned to each of the schools in the pool
  
- **Cap**: sum of the raw caps of the schools in the pool as defined in [Who Will Order Devices](./who_will_order_devices.md) for individually managed schools. Note that, if the school is set to `cannot_order`, its raw_cap matches the number of devices already ordered by that school so far.
  
- **Devices Ordered**: sum of devices ordered by each school in the pool.
  
We can easily understand this via an example:

School A:
```
school_a.order_state #=> 'can_order'
school_a.raw_laptop_allocation #=> 10
school_a.circumstances_laptops #=> 0
school_a.over_order_reclaimed_laptops #=> 0
school_a.raw_laptops_ordered  #=> 0
```

that means this school was allocated 10 laptops, 10 (10-0-0) is the maximum number that could be ordered (raw cap) and it has ordered 0 laptops so far:
```
school_a.raw_laptops #=> [10, 10, 0] # raw_allocation: 10, raw_cap: 10, devices_ordered: 0 for laptops
```

School B, in the same pool, has these numbers:
```
school_b.order_state #=> 'can_order_for_specific_circumstances'
school_b.raw_laptop_allocation #=> 10
school_b.circumstances_laptops #=> -3
school_b.over_order_reclaimed_laptops #=> 0
school_b.raw_laptops_ordered #=> 0
```
so 
```
school_b.raw_laptops #=> [10, 7, 0]
```

Similarly, a third school in the pool, School C:
```
school_c.order_state                  #=> 'cannot_order'
school_c.raw_laptop_allocation        #=> 10
school_c.circumstances_laptops        #=> 0
school_c.over_order_reclaimed_laptops #=> 0
school_c.raw_laptops_ordered          #=> 0
```
so
```
school_c.raw_laptops #=> [10, 0, 0] # raw_cap is 0 instead of (10-0-0) because the school is set to can't order devices.
```

Therefore, if these are all the schools in the vcap, we can say:

- vcap allocation equals to 30 laptops
- vcap cap equals to 20 laptops (maximum number of laptops allowed to be ordered)
- vcap laptops ordered equals to 0 (laptops ordered so far by all the schools in the pool)

When the vcap gets computed, their 3 allocation number fields gets populated like this:
```
vcap.laptop_allocation: 30
vcap.laptop_cap: 20
vcap.laptops_ordered: 0
```
We can get these numbers listed together with the #laptops method:
```
vcap.laptops #=> [30, 20, 0]
```


## Placing devices orders
[Computacenter outgoing api](./computacenter_outgoing_api.md) document describes how GHwT system reports individual school and vcap allocation numbers to the supplier (Computacenter) for the users to place device orders.

When a user places an order in the suppliers portal (CC's TechSource website) it will get reported instantaneously back to GHwT so that individual school and vcap allocation numbers get inmediately updated accordingly.

In the example described above, CC should not allow orders to be put on School C given that it is set to `cannot order.` Let's say an order for 7 devices is put on School A. That would result in the following updates:
```
school_a.raw_laptops #=> [10, 10, 7]
school_b.raw_laptops #=> [10,  7, 0]
school_c.raw_laptops #=> [10,  0, 0]
vcap.laptops         #=> [30, 17, 7]
```

If later on, the responsible body associated to these schools decides to send all the remaining devices in the pool to School A, it might put a new order on it so the updated numbers for the pool would be like this:
```
school_a.raw_laptops #=> [10, 17, 17]
school_b.raw_laptops #=> [10,  0, 0]
school_c.raw_laptops #=> [10,  0, 0]
vcap.laptops         #=> [30, 17, 17]
```

If we dig even deeper into the schools new numbers it would show this:
```
school_a.raw_laptops #=> [10,  0,  7, 17] # allocation: 10, circumstances: 0, over_order_reclaimed: +7, ordered: 17
school_b.raw_laptops #=> [10, -3, -7,  0] 
school_c.raw_laptops #=> [10,  0,  0,  0]
vcap.laptops         #=> [30,    17,  17]
```

A few things to note:
- School A has borrowed 7 devices from School B (over_order_reclaimed_laptops column)
- School A cap has automatically been increased from 10 to 17 (10-0+7)
- School A cap and devices ordered are higher than the initial school allocation
- School B cap has lent 7 devices to School A (-7 over ordered reclaimed devices)
- School B cap has decreased automatically from 10 devices allocated to 0 (3 and 7 devices have gone away because of cicumstances status and over order lend)
- The pool cap (17 devices) has been fully ordered. CC should not allow any more orders on this vcap even though the overall allocation is higher (30) but 10 of them cannot be ordered and 3 went away after setting School B to `can_order_for_specific_circumstances`
- Even though technically School A has ordered more devices than allocated, the whole vcap is not in over order status because total devices ordered (17) does not surpass the total cap of the pool (17).

If for some reason, CC allows extra orders on this vcap, the last point wouldn't be true any longer so in that case, we say the vcap is in `over order`:
```
school_a.raw_laptops #=> [10,  0,  8, 18, :can_order]    which makes [10, 18, 18]
school_b.raw_laptops #=> [10, -3, -7,  0, :can_order]    which makes [10,  0,  0]
school_c.raw_laptops #=> [10,  0,  0,  0, :cannot_order] which makes [10,  0,  0]
vcap.laptops         #=>                                             [30, 18, 18]
```

Note that the vcap is in over order even though there are 10 devices allocated (but not available) on School C.
This is an edge case. Normally over orders happens when the number of devices ordered is higher than the overall allocation of the pool:
```
school_a.raw_laptops #=> [10, 0,  21, 31, :can_order] which makes [10, 31, 31]
school_b.raw_laptops #=> [10, 0, -10,  0, :can_order] which makes [10,  0,  0]
school_c.raw_laptops #=> [10, 0, -10,  0, :can_order] which makes [10,  0,  0]
vcap.laptops         #=>                                          [30, 31, 31] 
```
21 devices borrowed but only 20 lent. That makes 1 over ordered device.
