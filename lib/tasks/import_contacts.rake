namespace :import do
  desc 'Import contacts from url specified in CONTACTS_FILE_URL env-var'
  task contacts: :environment do
    ImportContactsService.new.import_contacts
  end
end
