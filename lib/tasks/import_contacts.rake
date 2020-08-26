namespace :import do
  desc 'Import contacts from url specified in CONTACTS_FILE_URL env-var'
  task contacts: :environment do
    ImportContactsService.new.import_contacts
  end

  desc 'Import RB users from computacenter CSV file at RB_USERS_CSV_URL'
  task rb_users_from_cc_csv: :environment do
    ImportResponsibleBodyUsersFromComputacenterCsvService.new(ENV['RB_USERS_CSV_URL'])
  end
end
