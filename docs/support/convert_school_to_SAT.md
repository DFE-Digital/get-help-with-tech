### Convert a non-maintained School to a SAT

There are cases where schools (typically special schools and FE colleges) have been imported and assigned to the Local Authority as their responsible body because there was no or incomplete trust information in the GIAS data file (and the logic uses the LA unless there is Trust info in the data file).

These typically only come to light where the LA contacts support and asked for the school to be removed from their list of schools.

The decision has been made that we will treat these cases a Single Academy Trusts. Normally all trusts require a Companies House Number and this is used by Computacenter for credit checking type of activities. However CC have agreed that as the schools are not actually purchasing anything the CHN can be blank for these SATs.

#### Before converting

Check the GIAS website for the school's details and see if the school has a website. Take a look on the school's website and see if there is a suitable trust name that could be used and possibly a CHN.  I have seen this sort of thing in the main page footer for example for a school named "St. Elizabeth's School":

```
St Elizabeth's Centre is a company limited by guarantee registered in England and Wales (No. 12345678)
Registered Charity No: 1234567
```

So it would make sense to use the name "St. Elizabeth's Centre" for the SAT and the CHN.

If nothing suitable is found the default is to use the school name and blank CHN.

#### Converting the school

Create an instance of the `SchoolToSatConverter` and pass it an instance of the `School`

```ruby
stsc = SchoolToSatConverter.new(School.find_by(urn: 123456))
```

Invoke the `convert_to_sat` method

```ruby
stsc.convert_to_sat(trust_name: 'Trust Name Here', companies_house_number: '12345678')
```

Or when no extra information is available, simply

```ruby
stsc.convert_to_sat
```

This creates a single academy trust, moves the school to that trust and creates or adjusts the `preorder_information` to set the school as the ordering body.  It will also create a zero `std_device_allocation` if one doesn't already exist.

### Notify Computacenter

We need to let Computacenter know of changes to the school and the new trust.  As we've added a new trust we need to export it to a CSV file and send it to CC so that they can send us a `soldTo` number (`computacenter_reference`)

Select the trust and use the `ResponsibleBodyExporter` to generate a CSV for CC:

```ruby
[15] pry(main)> ResponsibleBodyExporter.new('public/rb-changes.csv').export_responsible_bodies(Trust.where(name: 'Trust Name Here'))
=> nil
```

Select the school and use the `SchoolDataExporter` to generate a CSV for CC:

```ruby
SchoolDataExporter.new('public/school-changes.csv').export_schools(School.where(urn: 123456))
```

You should be able to download the files with your browser by entering the file name directly after the prod site url as the rails server is currently set to serve static assets

```
https://get-help-with-tech.education.gov.uk/rb-changes.csv
https://get-help-with-tech.education.gov.uk/school-changes.csv
```

Once downloaded, remember to remove the files from the server from the SSH command line

```bash
$ rm public/rb-changes.csv
$ rm public/school-changes.csv
```

Finally open the CSV files in a suitable editor and append an extra column at the end with the header "New/Amended".  For the new trust row in the file indicate that it is a "New" record, for the school it will be an "Amended" record and  to make it easier for CC to process.

Email the CSV files to  CC.

CC will return the file with `soldTo` references added. These should be used to update the `computacenter_reference` for the trust.  Sometimes if a school is added at the same time, only the school data is returned, but the school will have a `soldTo` which is the same reference for the trust, so that can be used to set the trust's `computacenter_reference`.

