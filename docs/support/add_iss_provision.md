# Add an ISS Provision

An Independent Special School (ISS) Provision allows a `LocalAuthority`, a type of `ResponsibleBody`, 
to order devices on behalf of students in independent special schools. These are typically pupils
whose fees are being paid for them in order to attend an independent special school which can
better cater to their needs than a state school.

An ISS Provisioned `LaFundedPlace`, a type of `School`, will always have the same name 
"State-funded pupils in independent special schools and alternative provision". In our system it's 
modelled as a `School` but really it isn't: it's just a representation of a number of pupils at 
different ISSs overseen by a single `LocalAuthority`. Thereby the `name` attribute has to be 
generic. 

## Create the ISS Provision

Details will be provided from elsewhere in the business (currently collected via a Google Form).

First locate the "Local authority code" (this is what service users typically call the Get 
Information About Schools (GIAS) code).

In the rails console find the `LocalAuthority` by GIAS code:

```ruby
la = LocalAuthority.find_by_gias_id(845) # where the local authority code is 845
```

Create the ISS provision for the `LocalAuthority` that you found and assign the new ISS aka `LaFundedPlace` that is 
created to a variable:

```ruby
lafp = la.create_iss_provision!
```

Here is the method:
[def create_iss_provision!](https://github.com/DFE-Digital/get-help-with-tech/blob/05a30daf5e09475b2d6cccedd5178e11a028647b/app/models/local_authority.rb#L23-L30) This will return the ISS if it already exists.

## Update the details for the ISS Provision

Interested LocalAuthorities will provide delivery details for the ISS Provision. This address will be used to complete the contact details for the new LaFundedPlace object:

```ruby
lafp.address_1='123 Fake Street'
lafp.address_2="Dummy Crescent"
lafp.town='Townsville'
lafp.county='Sussex'
lafp.postcode='BN1 2AA'
lafp.phone_number='0123 456 78'

lafp.save!
```

## Users

The users associated with the `LocalAuthority` aka the `ResponsibleBody` will automatically be associated with the 
new `LaFundedPlace` aka ISS. You can check by comparing the following counts:

```ruby
lafp.users.count == lafp.responsible_body.users.count # should return `true`
```

You can also check the specs [here](https://github.com/DFE-Digital/get-help-with-tech/blob/05a30daf5e09475b2d6cccedd5178e11a028647b/spec/models/local_authority_spec.rb#L6)

## Post creation

We need to wait for the supplier to confirm that they have updated their system to include the new LaFundedPalce before we add the allocations.
Whether you are coming back to the same console session or starting a new console session you should ensure that you have the ``lafp`` variable set correctly:

````ruby
urn=845;lafp=School.find_by_provision_urn("ISS#{urn}")
````

Inspect the ``lafp`` variable to ensure that it correctly reflects the LaFundedPlace that you want to update.

### Adding allocations

```ruby
UpdateSchoolDevicesService.new(school: lafp,
                               laptop_allocation: 58,
                               laptop_cap: 58,
                               router_allocation: 18, 
                               router_cap:18)
```

### Supplier references

The supplier will eventually (and manually) see the information on the new school and manually add their references 
within the portal.

Once the supplier reference has been set we should set the school status to `can_order`.

```ruby
lafp.update!(order_state: 'can_order')
```

### Invitation to order

Once the ISS has been properly configured and the supplier has added their references we can send the e-mails inviting 
the users to order. The emails are normally sent by the support team.

#### Invite to order checklist

* ISS is created?
* Allocations have been added?
* LocalAuthority has delivery address?
* Supplier has added references?
* When all above are TRUE it is OK to send invites
