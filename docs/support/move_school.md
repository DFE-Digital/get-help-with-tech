# Move an existing school to a different RB

This can happen commonly with academy conversions but also without the school changing the URN (closing and reopening). Mostly the school will have closed and reopened with a new URN. When a request has come in from a RB asking for the school to be included, they often won't include the URN.  If the school has changed URN then there may be an existing school (under the closed URN) in the service and the current school with a new URN in the `DataStage`. The school might've renamed in the process too.

Find the school in the `DataStage` area to check that it hasn't in fact closed and reopened with a new URN.

```ruby
[1] pry(main)> ss = DataStage::School.find_by(urn: 123456)
```

or

```ruby
[1] pry(main)> ss = DataStage::School.where("name like '%School Name%'")
```

If the school has closed/reopened then follow the procedure to add a new school (see add_missing_school.md).



Get the school from the school table

```ruby
[1] pry(main)> s = School.find_by(urn: 123456)
```

Check that the receiving responsible body exists (if it does not then that will need to be added first)

```ruby
[2] pry(main)> rb = ResponsibleBody.find_by(name: ss.responsible_body_name)
```

Move the school to the new RB

```ruby
[1] pry(main)> s.update!(responsible_body: rb)
```



__NOTE:__ So far I haven't had to deal with users accounts when doing this, but we should work out how this should be handled.



## Notify Computacenter

We need to let Computacenter know of the changes.  As we've moved the school to a new RB, we need to export it to a CSV file and send it to CC so that they can update their records.  In these cases CC seem to keep the existing `shipTo` number (`computacenter_reference`) for the school but add the new `soldTo` reference for the RB. 

Select the schools to include and use the `SchoolDataExporter` to generate a CSV for CC.  I normally create this in the `public` folder under the rails root:

```ruby
[15] pry(main)> SchoolDataExporter.new('public/school-changes.csv').export_schools(School.where(urn: [147860,138156]))
=> nil
```
You should be able to download the file with your browser by entering the file name directly after the prod site url as the rails server is currently set to serve static assets

```
https://get-help-with-tech.education.gov.uk/school-changes.csv
```

Once downloaded, remember to remove the files from the server from the SSH command line

```bash
$ rm public/school-changes.csv
```

Finally open these CSV files in a suitable editor and append an extra column at the end with the header "New/Amended".  For each moved school set this value to 'Amended' to make it easier for CC to process.

Email the CSV files to  CC.

CC will return the file with `shipTo` and `soldTo` references added. These should be checked against the school and RB and updated if necessary.

