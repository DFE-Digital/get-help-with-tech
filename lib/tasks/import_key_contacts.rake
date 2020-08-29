namespace :import do
  desc 'Import RB key contacts from url specified in KEY_CONTACTS_FILE_URL env-var'
  task key_contacts: :environment do
    KeyContactsImporter.import_from_url(ENV.fetch('KEY_CONTACTS_FILE_URL'))
  end
end
