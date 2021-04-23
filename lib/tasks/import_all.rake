namespace :import do
  desc 'Import all based data required to run the service locally'
  task all: %i[responsible_bodies
               schools
               process_schools_data
               personas]
end
