# Add an ISS Provision

An ISS Provision allows a LocalAuthority aka a ResponsibleBody to order devices on behalf of students in independent special schools.

The ISS Provision aka LaFundedPlace < School will have the name "State-funded pupils in independent special schools and alternative provision"

## Create the ISS Provision

First locate the ```Local authority code```

In the rails console find the LocalAuthority:

````ruby
la = LocalAuthority.find_by_gias_id(845)
````

Create the ISS provison for the LocalAuthority that you found and assign the new ISS aka LaFundedPlace that is created it to a variable:

````ruby
lafp = la.create_iss_provision!
````

Here is the method:
[def create_iss_provision!](https://github.com/DFE-Digital/get-help-with-tech/blob/05a30daf5e09475b2d6cccedd5178e11a028647b/app/models/local_authority.rb#L23-L30) This will return the ISS if it already exists.

## Update the details for the ISS Provision

Complete the contact details:

````ruby
lafp.address_1='123 Fake Street'
lafp.address_2="Dummy Crescent"
lafp.town='Townsville'
lafp.county='Sussex'
lafp.postcode='BN1 2AA'
lafp.phone_number='0123 456 78'
````

And save!

````ruby
lafp.save
````

## Users

The users associated with the LocalAuthority aka the ResponsibleBody will automatically be associated with the new LaFundedPlace aka ISS. You can check by comparing the following counts:

````ruby
lafp.users.count
lafp.responsible_body.users.count
````

You can also check the specs [here](https://github.com/DFE-Digital/get-help-with-tech/blob/05a30daf5e09475b2d6cccedd5178e11a028647b/spec/models/local_authority_spec.rb#L6)

## Post creation

### Mising LocalAutority contact details

Ensure that you have the ``la`` and ``lafp`` set correctly:

````ruby
urn=845;la=LocalAuthority.find_by_gias_id("#{urn}");lafp=School.find_by_provision_urn("ISS#{urn}")
````

Copy the address details from the LaFundedPlace that you just added:

````ruby
la.address_1=lafp.address_1;la.address_2=lafp.address_2;la.address_3=lafp.address_3;la.town=lafp.town;la.county=lafp.county;la.postcode=lafp.postcode;la
````

Review and save!

````ruby
la.save
````

### Supplier references

The supplier will receive the information on the new school and add their references in the portal.

### Invitation to order

Once the ISS has been properly configured and the supplier has added their references we can send the emails inviting the users to order.
