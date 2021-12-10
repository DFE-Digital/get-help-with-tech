# Computacenter Outgoing API

## Table of contents

- [Access](#access)
- [Available endpoints](#available-endpoints)
  * [Cap Usage Request](#cap-update-request)
    + [Example](#example)
    + [Responses](#responses)
    + [How capAmount values are calculated](#how-capamount-values-are-calculated)

## Access

The Computacenter outgoing API is an HTTP Rest api authenticated via BASIC AUTH. There is no public access.
See settings on each environment for credentials and connection details.

## Available endpoints

### Cap Update Request

This endpoint allows you to POST a batch of cap updates to CC servers.

It should be hit every time the cap of a school changes for whatever reason (order_state change, allocation change, devices ordered change, ...)

It expects a request body which is valid XML with a Record tag per school reported.

It is only via this api that the supplier (CC) knows about the maximum number of devices authorised users can order for a school.

#### Example:

Given this XML packet in the body -
```xml
<?xml version="1.0" encoding="UTF-8"?>"
  <CapAdjustmentRequest payloadID="f0da1ff1-2167-4381-b305-95913742d605" dateTime="2021-11-12T11:28:30+00:00">"
  <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81090176" capAmount="127"/>"
  <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81090178" capAmount="127"/>"
  <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81090182" capAmount="127"/>"
  <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81090183" capAmount="127"/>"
  <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81090181" capAmount="127"/>"
</CapAdjustmentRequest>
```

it will report CC the `capAmount` allowed for each school in a record. See below for an explanation on the way these values are calculated.

#### Responses

##### Success
If all `Record`s are processed successfully:

* The response status code will be `200 OK`
* the `<HeaderResult>` `status` attribute will be `Success`
* the response body will look like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CapAdjustmentResponse dateTime="2021-12-09T17:40:18Z" payloadID="4dae8ccb-ab4f-43b9-b276-26d3088a080d">
  <HeaderResult piMessageID="133694cc591711ecb6d40000003999e6" status="Success"/>
  <FailedRecords/>
</CapAdjustmentResponse>
```

##### Failure
* The response status code will be `422 Unprocessable Entity`
* the `<HeaderResult>` `status` attribute will be `failed`
* the response body will give details of the failure


#### How capAmount values are calculated
The devices supplier (CC currently) keeps records of the devices ordered by any school at anytime.
Actually, given that user orders are put in their portal, the supplier knows first-hand the right number of devices ordered by any school.

It is DfE responsability to keep CC updated with the maximum number of devices each school can order (`capAmount`) at any time by hitting this api endpoint whenever that number changes.

#### Schools individually managed
For a school individually managed, all CC needs as `capAmount` for that school is simply the `raw_cap` value for each device type (`laptop` and `router`).
Once they get those values, they can easily calculate the number of remaining devices available to order:

```
laptopsRemainingToOrder(school) = capAmount(school, :laptop) - devicesOrdered(school, :laptop)
routersRemainingToOrder(school) = capAmount(school, :router) - devicesOrdered(school, :router)
```

#### Schools centrally managed
With virtual cap pools and the shared caps, we must generate cap update requests whenever the cap amount of the pool changes. The change must be sent to Computacenter for all schools in that pool according to the expression:

```
capAmount(school, device_type) = if school.cannot_order? 
                                   school.raw_cap(device_type)
                                 else
                                   school.vcap_cap(device_type) - school.vcap_devices_ordered(device_type) + school.raw_devices_ordered(device_type)
                                 end
```
Therefore, the capAmount sent to CC for each school in the vcap is the overall number of devices remaining to order in the pool increased by the number of devices ordered so far by each particular school.
When CC computes the available devices to order for a school:
```
laptopsRemainingToOrder(school) = capAmount(school, :laptop) - devicesOrdered(school, :laptop)
routersRemainingToOrder(school) = capAmount(school, :router) - devicesOrdered(school, :router)
```

the result for all the schools in the pool will be exactly the overall number of devices still available to order in the shared pool.

Note that for schools in the vcap set to `cannot_order`, the `capAmount` value sent to CC matches the number of devices ordered by the school so far.
This way, the resulting remaining devices to order for those schools will be 0 (no more devices can be ordered).

#### Example:
```
Vcap School A (can_order):    [10, 10, 3] #=> capAmount: 20 - 3 + 3 = 20
Vcap School B (can_order):    [10, 10, 0] #=> capAmount: 20 - 3 + 0 = 17
Vcap School C (cannot_order): [10,  0, 0] #=> capAmount: 0
Vcap:                         [30, 20, 3] #> 20 - 3 = 17 devices available to order                
```

On CC side, after receiving these cap updates, the calculations will be:
```
devicesRemainingToOrder(school_A) = 20 - 3 = 17
devicesRemainingToOrder(school_B) = 17 - 0 = 17
devicesRemainingToOrder(school_C) =  0 - 0 =  0
```
