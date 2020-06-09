def create_valid_user
  User.create(full_name: 'Jane Doe', organisation: 'Some Local Authority', email_address: 'jane.doe@somelocalauthority.gov.uk')
end

def destroy_valid_user
  User.where(email_address: 'jane.doe@somelocalauthority.gov.uk').destroy_all
end
