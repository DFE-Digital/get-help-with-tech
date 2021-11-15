# Add a Further Education College that is not on the service

You can lookup educational institutions on these sites

https://www.get-information-schools.service.gov.uk/

https://www.ukrlp.co.uk/

To add a Further Education College, login to the production server.

```ruby
cf login --sso
make prod ssh
unset RAILS_LOG_TO_STDOUT
bundle exec rails c
```

Look to see if the school already exists using it's ukprn.

```ruby
[1] pry(main)> School.find_by ukprn: 10019293
=> nil
```

If it does not exist then first create a responsible body, in this case a FurtherEducationCollege

```ruby
rb = FurtherEducationCollege.new
rb.name = 'ASPHALEIA LIMITED'
[13] pry(main)> FurtherEducationCollege.pluck(:organisation_type).uniq
=> ["FurtherEducationSchool"]
[14] pry(main)> rb.organisation_type = 'FurtherEducationSchool'
rb.default_who_will_order_devices_for_schools = 'school'
rb.address_1 = ...
rb.address_2 = ...
rb.address_3 = ...
rb.town = ...
rb.county = ...
rb.postcode = ...
[25] pry(main)> rb
=> #<FurtherEducationCollege:0x00007fb11f3d8dd0
 id: nil,
 type: "FurtherEducationCollege",
 name: "ASPHALEIA LIMITED",
 organisation_type: "FurtherEducationSchool",
 local_authority_official_name: nil,
 local_authority_eng: nil,
 companies_house_number: nil,
 created_at: nil,
 updated_at: nil,
 who_will_order_devices: "school",
 computacenter_reference: nil,
 gias_group_uid: nil,
 gias_id: nil,
 key_contact_id: nil,
 address_1: "22 Liverpool Gardens",
 address_2: nil,
 address_3: nil,
 town: "Worthing",
 county: nil,
 postcode: "BN11 1RY",
 status: "open",
 vcap_feature_flag: false,
 computacenter_change: "none",
 new_fe_wave: true>
```

Then add the actual school, FurtherEducationSchool

```ruby
school = FurtherEducationSchool.new(responsible_body: rb)
school.name = ...
school.address_1 = ...
school.address_2 = ...
school.address_3 = ...
school.town = ...
school.county = ...
school.postcode = ...
school.hide_mno = true
[46] pry(main)> school
=> #<FurtherEducationSchool:0x00007fb12019df60
 id: 22720,
 urn: nil,
 name: "Asphaleia Limited",
 computacenter_reference: nil,
 responsible_body_id: 3884,
 created_at: Wed, 07 Apr 2021 15:27:44.519871000 BST +01:00,
 updated_at: Wed, 07 Apr 2021 15:27:44.519871000 BST +01:00,
 address_1: "22 Liverpool Gardens",
 address_2: nil,
 address_3: nil,
 town: "Worthing",
 county: nil,
 postcode: "BN11 1RY",
 phase: nil,
 establishment_type: nil,
 phone_number: "01243 531600",
 order_state: "cannot_order",
 status: "open",
 increased_allocations_feature_flag: false,
 computacenter_change: "new",
 increased_sixth_form_feature_flag: false,
 increased_fe_feature_flag: false,
 hide_mno: true,
 type: "FurtherEducationSchool",
 ukprn: 10019293,
 fe_type: nil,
 opted_out_of_comms_at: nil>
```

## Change Allocation

### Through the web interface

- in web interface find school
- change allocation to specified number
- on school invite user
- set name, email and yes can order devices
- on school change `Can they place orders?` to `They can order their full allocation because a closure or group of self-isolating children has been reported`
