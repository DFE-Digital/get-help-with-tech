# Add a school that is not on the service

Find the school in the `DataStage` area.  If it is not there then it is outside of the types of establishments onboarded to the service.

```ruby
ss = DataStage::School.find_by(urn: 123456)
```

Check that the responsible body exists (if it does not then that will need to be added first)

```ruby
t = ResponsibleBody.find_by(name: ss.responsible_body_name)
```

Add the school using the `SchoolUpdateService`

```ruby
sus = SchoolUpdateService.new
```

```ruby
s = sus.send(:create_school, ss)
```

This will create the school based on the attributes in the `DataStage::School`. If the responsible body has answered the 'who will order' question, this will also create `preorder_information` and a `std_device_allocation` with a zero allocation.

## When the school has predecessor school(s)

Check whether the school was added as the result of a 'closing' and 'reopening' an existing school (e.g. academy conversion or amalgamation) that may already have had an allocation

```ruby
ss.school_links
```

If there's a predecessor link, look up the school using the`link_urn` and if it exists in the system check its device allocations

```ruby
School.find_by(urn: 123436)&.device_allocations
```

Confirm that the predecessor is closed in the `DataStage`

```ruby
DataStage::School.find_by(urn: 123436)
```

Mark the predecessor as closed in the service

```ruby
School.find_by(urn: 123436).gias_status_closed!
```

#### Transferring the device allocation

If there is an existing allocation, move the values to the new school (I've only moved `allocation` so far as the other values have been zero - if this is not the case you might need to work our what needs to happen, e.g. move the remaining allocation amount, or not - best check with the support colleagues) and reset the allocation on the old school.

If you change/move the allocation you need to inform Charlotte/Anya know so that the allocations spreadsheet can be updated.

If there were no links and the school is in the allocations spreadsheet, use the allocation from the there and update the `std_device_allocation.allocation`with the value.

#### Moving Users

Check whether the predecessor school had users that could be moved the the new school.  It may not always make sense to move users, in cases where a school have moved trusts or converted to an academy it is likely that any existing users would now have new email addresses.

To move a user, the user needs to have the association removed between ot the old school and one added for the new school.

```ruby
old_school.users
```

Add users to new school

```ruby
old_school.users.each { |u| s.users << u }
```

Remove a user from the old school (doesn't destroy the user object)

```ruby
old_school.users.destroy(user)
```

Remove all users from the old school (doesn't destroy the user objects)

```ruby
old_school.users.destroy_all
```



## Notify Computacenter

### Schools changes

We need to let Computacenter know of changes to schools or new schools.  As we've added a new school we need to export it to a CSV file and send it to CC so that they can send us a `shipTo` number (`computacenter_reference`)

Select the schools to include and use the `SchoolDataExporter` to generate a CSV for CC.  I normally create this in the `public` folder under the rails root:

```ruby
SchoolDataExporter.new('public/school-changes.csv').export_schools(School.where(urn: [147860,138156]))
```
Repeat for any new or updated responsible bodies using the `ResponsibleBodyExporter`:
```ruby
ResponsibleBodyExporter.new('public/responsible-body-changes.csv').export_responsible_bodies(Trust.where(id: 3444))
```

You should be able to download the file with your browser by entering the file name directly after the prod site url as the rails server is currently set to serve static assets

```
https://get-help-with-tech.education.gov.uk/school-changes.csv
```

Once downloaded, remember to remove the files from the server from the SSH command line

```bash
$ rm public/school-changes.csv
```

Finally open these CSV files in a suitable editor and append an extra column at the end with the header "New/Amended".  For each row in the file indicate whether the row is a "New" or "Amended" record to make it easier for CC to process.

Email the CSV files to  CC.

CC will return the file with `shipTo` references added. These should be used to update the `computacenter_reference` for the school.  Sometimes if a trust is added at the same time, only the school data is returned, but the school will also have a `soldTo` reference which is the `computacenter_reference` for the trust, so that can be used to update trust.

### User changes

__TODO:__ Computacenter need to be updated if user accounts are moved between schools, this needs to be worked out and handled in conjunction with the automated notifications.

