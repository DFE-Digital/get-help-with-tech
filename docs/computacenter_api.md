# Computacenter API

## Authentication

### Generating an API token

API tokens are managed through the user interface.

First, sign in to the user interface:

1. Login to the interface by visiting the site in a web browser, and clicking
'Sign in' from the top navigation bar
2. Enter your email address - this must end with `@computacenter.com` - and
if you have a user account setup, we'll email you a 'magic link'
3. Click on this magic link to sign in

Next, click on 'API tokens' from the top navigation bar. You'll see any
API tokens you currently have, and a form to generate a new token.

Give your token a name (this is purely for your own reference) and click
'Generate'. You should see your new token in the table of 'Your API Tokens'

Copy the value in the 'Token' column - this will be the Bearer token you supply
to the API with each request

### Supplying an API token

For each request to the Computacenter API, you must provide a 'Bearer token in
the `Authorization` header. You can do this with `curl` using the `-H` flag:

```bash
# replace YOUR_TOKEN_VALUE with your token, and API_URL with the actual
# endpoint URL
curl -H "Authorization: Bearer YOUR_TOKEN_VALUE" API_URL
```
## Available Endpoints

### Cap Usage Bulk Update

`POST /computacenter/api/cap-usage/bulk-update`

This endpoint allows you to POST a batch of cap usage updates.
It expects a request body which is valid XML, and which is also valid against
[the schema](../config/computacenter/api/schema/CapUsage.xsd)

Example:

Given this XML packet in the body -
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CapUsage payloadID="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-06-18T09:20:45Z" >
  <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="100" usedCap="20"/>
  <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060874" capAmount="200" usedCap="100"/>
  <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060875" capAmount="300" usedCap="57"/>
  <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060875" capAmount="400" usedCap="100"/>
  <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060876" capAmount="500" usedCap="200"/>
  <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060876" capAmount="600" usedCap="267"/>
</CapUsage>
```

- it will update the device allocations for the matching school / device type combinations to the given `capAmount` values.

#### Responses

##### Success

If all `Record`s are processed successfully:

* The response status code will be `200 OK`
* the `<HeaderResult>` `status` attribute will be `succeeded`
* the response body will look like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CapUsageResponse payloadId="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-08-14T16:47:12Z">
  <HeaderResult status="succeeded">
    <FailedRecords />
  </HeaderResult>
</CapUsageResponse>
```

##### Failure
If all `Record`s fail:

* The response status code will be `422 Unprocessable Entity`
* the `<HeaderResult>` `status` attribute will be `failed`
* the response body will give details of each failure, like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CapUsageResponse payloadId="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-08-14T16:47:12Z">
  <HeaderResult status="partially_failed">
    <FailedRecords>
      <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060874" capAmount="200" usedCap="100" status="failed" errorDetails="Couldn't find SchoolDeviceAllocation"/>
      <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060875" capAmount="300" usedCap="57" status="failed" errorDetails="Couldn't find School"/>
      <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060875" capAmount="400" usedCap="100" status="failed" errorDetails="Couldn't find School"/>
      <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060876" capAmount="500" usedCap="200" status="failed" errorDetails="Couldn't find School"/>
      <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060876" capAmount="600" usedCap="267" status="failed" errorDetails="Couldn't find School"/>
    </FailedRecords>
  </HeaderResult>
</CapUsageResponse>
```

##### Partial Failure

If some, but not all, `Record`s fail:

* The response status code will be `207 Multi-status`
* the `<HeaderResult>` `status` attribute will be `partially_failed`
* the response body will give details of each failure, like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CapUsageResponse payloadId="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-08-14T16:47:12Z">
  <HeaderResult status="partially_failed">
    <FailedRecords>
      <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060874" capAmount="200" usedCap="100" status="failed" errorDetails="Couldn't find SchoolDeviceAllocation"/>
      <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060875" capAmount="300" usedCap="57" status="failed" errorDetails="Couldn't find School"/>
      <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060875" capAmount="400" usedCap="100" status="failed" errorDetails="Couldn't find School"/>
      <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060876" capAmount="500" usedCap="200" status="failed" errorDetails="Couldn't find School"/>
      <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060876" capAmount="600" usedCap="267" status="failed" errorDetails="Couldn't find School"/>
    </FailedRecords>
  </HeaderResult>
</CapUsageResponse>
```
