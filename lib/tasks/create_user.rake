desc 'Create a new user in an existing responsible body'
task :create_rb_user, %i[full_name email_address responsible_body_name] => :environment do |_t, args|
  CreateUserService.new.call(
    full_name: args[:full_name].strip,
    email_address: args[:email_address].strip,
    responsible_body_name: args[:responsible_body_name].strip,
  )
end
