# Restoring the database from a snapshot

## Introduction

The production and staging environments run on a highly-available configuration of dual Postgresql RDS instances. Snapshots are taken automatically every night, and retained for 7 days. In the event of a disastrous data problem, it may occasionally be necessary to restore the database to a previous snapshot. It's also possible to restore to any specific point in time within that 7 day window.
This document explains how to do so.

## Process

Full instructions are available from the [GOV.UK PaaS online documentation](https://docs.cloud.service.gov.uk/deploying_services/postgresql/#restoring-a-postgresql-service-snapshot) A simpler step-by-step guide is below.

You will need to be logged on to the GOV.UK PaaS CloudFoundry service:

`cf login -a api.london.cloud.service.gov.uk --sso`  

In this example, replace `(env)` with the name of the environment you are restoring (e.g. dev, staging, prod)

### Preparation

1. Set the target space to the environment you wish to restore:
`make (env) set_cf_target`

2. Get the service plan of the environments' database service:
`cf service get-help-with-tech-(env)-db | grep plan`

This will return a line something like:
`plan:             small-ha-11`
Note the plan name.

3. Get the GUID of the environments' database service:
`cf service get-help-with-tech-(env)-db --guid`

This will return a GUID, like:
`32938730-e603-44d6-810e-b4f12d7d109e`

4. Construct the JSON which defines the previous point in time to which you want to restore.


|To restore to| Use |
|-------------|-----|
|The latest snapshot|`{"restore_from_latest_snapshot_of": "(guid)"}`|
|The most recent snapshot taken before a point in time|`{"restore_from_latest_snapshot_of": "(guid)", "restore_from_latest_snapshot_before": "(datetime)"}`|
|A specific point in time between snapshots|`{"restore_from_point_in_time_of": "(guid)", "restore_from_point_in_time_before": "(datetime)"}`|

where `(guid)` is the GUID found in step 3, and `(datetime)` is the point in time, for example `2020-04-01 13:00:00`

5. Trigger the creation of a new service by running:

`cf create-service postgres (plan) (new service name) -c '(json)'`

where:
`(plan)` is the plan name from step 2
`(new service name)` is a unique name for the new database service (maybe something like `get-help-with-tech-db-restored`)
`(json)` is the JSON from step 4

This will take 5-10 minutes to run. You can check the progress with `cf service (new service name) | grep status:`
When it returns `status: create succeeded` then the new database service is ready to use.

6. Un-bind the existing database service from the app

This will take a few seconds to run, but *WILL CAUSE DOWNTIME FROM THIS POINT UNTIL STEP 8. IS COMPLETE*
`cf unbind-service get-help-with-tech-(env) get-help-with-tech-(env)-db`

7. Bind the newly-restored database service to the app

`cf bind-service get-help-with-tech-(env) (new service name)`

where `(new service name)` is the unique name for the restored database service from step 5. This should also complete within a few seconds.

8. Restage the app to force the construction of a new DATABASE_URL

`cf restage get-help-with-tech-(env)`

This may take up to a minute or so, but *once this is complete, the service will be back online.*

9. Edit the database service name in `config/manifests/(env)-manifest` to the new database service name

10. Submit the change from step 9 as a pull request 
