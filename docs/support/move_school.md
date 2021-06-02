# Move an existing school to a different RB

This can happen commonly with academy conversions (where the URN will change) but also without the school changing
URN (closing and reopening). Mostly the school will have closed and reopened with a new URN. When a request has 
come in from a RB asking for the school to be included, they often won't include the URN.  If the school has 
changed URN then there may be an existing school (under the closed URN) in the service and the current school 
with a new URN in the `DataStage`. The school might've renamed in the process too.

Find the school in the `DataStage` area to check that it hasn't in fact closed and reopened with a new URN.

```ruby
old_staged_school = DataStage::School.find_by(urn: OLD_URN)
new_staged_school = DataStage::School.find_by(urn: NEW_URN)
```

or

```ruby
new_staged_school = DataStage::School.where("name like '%School Name%'")
```

If the school has closed/reopened then follow the different procedure (add_missing_school.md) and disregard the below.

## Procedure to change RB for a school

Get the school from the school table

```ruby
School.find_by(urn: NEW_URN) # will be `nil`
s = School.find_by(urn: OLD_URN)
```

Check that the receiving responsible body exists (if it does not then that will need to be added first)

```ruby
rb = ResponsibleBody.find_by(name: new_staged_school.responsible_body_name)
```

Move the school to the new RB, assign the new URN, and indicate that this is new information for CC.

```ruby
s.update!(responsible_body: rb, urn: NEW_URN, computacenter_change: 'amended')
```

Since the statement above sets `computacenter_change` to `amended`, the changes should now be visible for CC users 
of our service at https://get-help-with-tech.education.gov.uk/computacenter/school-changes
(developers can verify this themselves by setting their `User`'s `is_computacenter` attribute to `true`).

For *all* RBs involved in the move, call 

```ruby
rb.calculate_virtual_caps! # recalculates virtual cap for the RB given the schools it now contains
```

CC need to see this so that they can update their records.  In these cases CC seem to keep the existing
`shipTo` number (`computacenter_reference`) for the school but update their records with the
new `shipTo` / `soldTo` relationship.

This leaves the existing preorder information, allocations and users still associated with the school.  
This might not be desired so further updates to these may be necessary or in some cases these can be handled later by 
support colleagues via the support portal.