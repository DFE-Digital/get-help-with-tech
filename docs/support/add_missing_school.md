# Add a school that is not on the service

These instructions may be relevant if you're moving a school between responsible bodies. Instead of
move_school.md, you'll want to use these steps if the school closed then reopened inside GIAS.

Find the school in the `DataStage` area. 
(If it is not there then it is outside of the types of establishments onboarded to the service. In this
case **you should not add it**.)

```ruby
staged_school = DataStage::School.find_by(urn: 123456)
```

Check that the responsible body exists (if it does not then that will need to be added first)

```ruby
staged_school.responsible_body
```

Create the school:

```ruby
school = SchoolUpdateService.new.create_school!(staged_school)
```

This will create the school based on the attributes in the `DataStage::School`. 
If the responsible body has answered the 'who will order' question, this will also create 
`preorder_information` and a `std_device_allocation` with a zero allocation.

## When the school has predecessor school(s)

Check whether the school was added as the result of 'closing' and 'reopening' an existing school 
(e.g. academy conversion or amalgamation) that may already have had an allocation

```ruby
staged_school.school_links
```

Close all open predecessor schools (which are now closed in the GIAS staged data):

```ruby
staged_school.predecessors.select(&:gias_status_open?).each do |s|
  s.gias_status_closed! if DataStage::School.find_by(urn: s.urn).gias_status_closed?
end
```

For other types of link (e.g. amalgamation), you will need to adjust the above step appropriately.

#### Transferring the device allocation

If there is an existing allocation, copy the values to the new school (I've only moved `allocation` so far as the other values have been zero - if this is not the case you might need to work our what needs to happen, e.g. move the remaining allocation amount, or not - best check with the support colleagues) and reset the allocation on the old school.

If you change/move the allocation you need to inform Charlotte/Anya know so that the allocations spreadsheet can be updated.

If there were no links and the school is in the allocations spreadsheet, use the allocation from the there and update the `std_device_allocation.allocation` with the value.

#### Moving Users

Check whether the predecessor school had users that could be moved the the new school.  It may not always make sense to move users, in cases where a school has moved trusts or converted to an academy it is likely that any existing users would now have new email addresses.

To move a user, the user needs to have the association removed between ot the old school and one added for the new school.

```ruby
old_school.users
```

Add users to new school

```ruby
old_school.users.each { |u| school.users << u }
```

Remove a user from the old school (doesn't destroy the user object)

```ruby
old_school.users.destroy(user)
```

Remove all users from the old school (doesn't destroy the user objects)

```ruby
old_school.users.destroy_all
```

If the moved users have TechSource accounts, notifications will be automatically generated and sent to CC.

Once Computacenter know of changes to schools or new schools they send us a `shipTo` number (`computacenter_reference`).
