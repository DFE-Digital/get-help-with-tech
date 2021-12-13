class Support::UserReport < TemplateClassCsv
  def self.headers
    %w[full_name
       email_address
       last_signed_in_at
       created_at
       user_rb_name
       user_rb_gias_group_uid
       user_rb_gias_id
       user_rb_laptop_allocation
       user_rb_laptop_cap
       user_rb_laptops_ordered
       school_name
       school_urn
       school_ukprn
       school_provision_urn
       school_raw_laptop_allocation
       school_raw_laptop_cap
       school_raw_laptops_ordered
       school_rb_name
       school_rb_gias_group_uid
       school_rb_gias_id
       privacy_notice_seen
       is_support
       is_computacenter
       rb_level_access
       deleted]
  end

private

  def add_headers
    csv << self.class.headers
  end

  def add_report_rows
    User.where(id: scope_ids).includes(:responsible_body, { schools: :responsible_body }).find_each do |user|
      schools = user.schools
      user_rb = user.responsible_body
      i = 0
      while i < schools.size || i.zero?
        school = schools[i]
        school_rb = school&.responsible_body
        csv << [
          user.full_name,
          user.email_address,
          user.last_signed_in_at,
          user.created_at,
          user_rb&.local_authority_official_name || user_rb&.name,
          user_rb&.gias_group_uid,
          user_rb&.gias_id,
          user_rb&.laptop_allocation,
          user_rb&.laptop_cap,
          user_rb&.laptops_ordered,
          school&.name,
          school&.urn,
          school&.ukprn,
          school&.provision_urn,
          school&.raw_allocation(:laptop),
          school&.raw_cap(:laptop),
          school&.raw_devices_ordered(:laptop),
          school_rb&.local_authority_official_name || school_rb&.name,
          school_rb&.gias_group_uid,
          school_rb&.gias_id,
          user.privacy_notice_seen_at ? 'true' : 'false',
          user.is_support ? 'true' : 'false',
          user.is_computacenter ? 'true' : 'false',
          user.rb_level_access ? 'true' : 'false',
          user.deleted_at ? 'true' : 'false',
        ]
        i += 1
      end
    end
  end
end
