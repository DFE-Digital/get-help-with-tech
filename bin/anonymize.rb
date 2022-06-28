require 'data-anonymization'

# Script to anonymise some PII fields in a get-help-with-tech database
#
# How to run:
#
#   get-help-with-tech> gem install data-anonymization
#   get-help-with-tech> ruby bin/anonymize.rb -d existing_local_get_help_with_tech_postgres_database_name
#
#
#
# This anonymisation step is part of bigger process to backup the real databases in dev, staging and prod environments:
#
# 1.- Create a dump of the original database. Ex: prod
#     get-help-with-tech> make prod dump_pass_db # this will place a prod.sql file in your home directory with all the sql sentences to restore the database as it is currently in prod environment.
#
# 2.- Create a new local database in postgresql to import the dump data. Use pgAdmin4 for instance.
#     Name it get-help-with-tech-prod for example.
#
# 3.- Restore the dump data into the new local database:
#     get-help-with-tech> psql --set ON_ERROR_STOP=on get-help-with-tech-prod < prod.sql
#
# 4.- Install data-anonymization if it is not already installed in your system.
#     get-help-with-tech> gem install data-anonymization
#
# 5.- Run this script to anonymise the data:
#     get-help-with-tech> ruby bin/anonymize.rb -d get-help-with-tech-prod
#
# 6.- Create a dump of the anonysized database. Use pgAdmin4 and store it in get-help-with-tech root folder
#
# 7.- Open Microsoft Azure Storage Explorer. (You need SAS credentials to access the DfE folder where to long-term store backups)
#
# 8.- Upload the anonymized backup file generated on step 5.
#
# Repeat steps 1-8 to backup the rest of environment databases: dev and staging
#
#
# How to restore any of our backups stored in Microsoft Azure Storage Explorer:
#
# 1.- Open Microsoft Azure Storage Explorer. (You need SAS credentials to access the DfE folder where to long-term store backups)
#
# 2.- Download the database file you are to restore and put it in get-help-with-tech root folder. Ex: get-help-with-tech-prod-anonym db
#
# 3.- Create a local postgres database named get-help-with-tech-prod for instance. Use pgAdmin4 or any other tool to do it.
#
# 4.- Restore the data in the dump file into the new database:
#     get-help-with-tech> pg_restore -d get-help-with-tech-prod -v get-help-with-tech-prod-anonym
#
# Repeat 1-4 steps to restore the rest of environment databases: dev and staging.

args = Hash[*ARGV]
dbname = "#{args['-d'] || args['--database']}"

DataAnon::Utils::Logging.logger.level = Logger::INFO

database dbname do
  strategy DataAnon::Strategy::Blacklist
  execution_strategy DataAnon::Parallel::Table

  source_db adapter: 'postgresql',
            host: 'localhost',
            database: dbname

  table 'computacenter_user_changes' do
    primary_key 'id'
    batch_size 1000

    anonymize('first_name').using FieldStrategy::RandomFirstName.new
    anonymize('last_name').using FieldStrategy::RandomLastName.new
    anonymize('email_address').using FieldStrategy::GmailTemplate.new
    anonymize('telephone').using FieldStrategy::RandomPhoneNumber.new
    anonymize('original_first_name').using FieldStrategy::RandomFirstName.new
    anonymize('original_last_name').using FieldStrategy::RandomLastName.new
    anonymize('original_email_address').using FieldStrategy::RandomMailinatorEmail.new
    anonymize('original_telephone').using FieldStrategy::RandomPhoneNumber.new
  end

  table 'email_audits' do
    primary_key 'id'
    batch_size 1000

    anonymize('email_address').using FieldStrategy::GmailTemplate.new
  end

  table 'extra_mobile_data_requests' do
    primary_key 'id'
    batch_size 1000

    anonymize('account_holder_name').using FieldStrategy::RandomFullName.new
    anonymize('device_phone_number').using FieldStrategy::RandomPhoneNumber.new
    anonymize('normalised_name').using FieldStrategy::RandomString.new
  end

  table 'preorder_information' do
    primary_key 'id'
    batch_size 1000

    anonymize('recovery_email_address').using FieldStrategy::GmailTemplate.new
  end

  table 'school_contacts' do
    primary_key 'id'
    batch_size 1000

    anonymize('email_address').using FieldStrategy::GmailTemplate.new
    anonymize('full_name').using FieldStrategy::RandomFullName.new
    anonymize('phone_number').using FieldStrategy::RandomPhoneNumber.new
  end

  table 'schools' do
    primary_key 'id'
    batch_size 1000

    anonymize('recovery_email_address').using FieldStrategy::GmailTemplate.new
  end

  table 'support_tickets' do
    primary_key 'id'
    batch_size 1000

    anonymize('full_name').using FieldStrategy::RandomFullName.new
    anonymize('email_address').using FieldStrategy::GmailTemplate.new
    anonymize('telephone_number').using FieldStrategy::RandomPhoneNumber.new
    anonymize('message').using FieldStrategy::LoremIpsum.new
  end

  table 'users' do
    primary_key 'id'
    batch_size 1000

    anonymize('full_name').using FieldStrategy::RandomFullName.new
    anonymize('email_address').using FieldStrategy::GmailTemplate.new
    anonymize('telephone').using FieldStrategy::RandomPhoneNumber.new
  end
end
