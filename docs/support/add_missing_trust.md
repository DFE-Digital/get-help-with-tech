# Add a Trust that is not on the service

Find the trust in the `DataStage` area.

```ruby
[1] pry(main)> st = DataStage::Trust.find_by(name: 'THE NEW TRUST')
```

Add the trust using the `TrustUpdateService`

```ruby
[3] pry(main)> tus = TrustUpdateService.new
```

```ruby
[4] pry(main)> t = tus.send(:create_trust, st)
```

This will create the trust based on the attributes in the `DataStage::Trust`.

## Notify Computacenter

We need to let Computacenter know of changes to responsible bodies as well a schools.  As we've added a new trust we need to export it to a CSV file and send it to CC so that they can send us a `soldTo` number (`computacenter_reference`)

Select the trusts to include and use the `ResponsibleBodyExporter` to generate a CSV for CC.  I now normally create this in the `public` folder under the rails root:

```ruby
[15] pry(main)> ResponsibleBodyExporter.new('public/rb-changes.csv').export_responsible_bodies(ResponsibleBody.where(name: 'THE NEW TRUST'))
=> nil
```

You should be able to download the file with your browser by entering the file name directly after the prod site url as the rails server is currently set to serve static assets

```
https://get-help-with-tech.education.gov.uk/rb-changes.csv
```

Once downloaded, remember to remove the files from the server from the SSH command line

```bash
$ rm public/rb-changes.csv
```

Finally open these CSV files in a suitable editor and append an extra column at the end with the header "New/Amended".  For each row in the file indicate whether the row is a "New" or "Amended" record to make it easier for CC to process.

Email the CSV files to  CC.

CC will return the file with `soldTo` references added. These should be used to update the `computacenter_reference` for the trust.  Sometimes if a school is added at the same time, only the school data is returned, but the school will have a `soldTo` which is the same reference for the trust, so that can be used to set the trust's `computacenter_reference`.