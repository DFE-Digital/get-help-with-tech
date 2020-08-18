namespace :export do
  desc 'Export responsible bodies to CSV'
  task :responsible_bodies, [:filename] => :environment do |_t, args|
    filename = args[:filename] || 'responsible_bodies.csv'
    ResponsibleBodyExporter.new(filename).export_responsible_bodies
  end

  desc 'Export school data to CSV'
  task :schools, [:filename] => :environment do |_t, args|
    filename = args[:filename] || 'schools.csv'
    SchoolDataExporter.new(filename).export_schools
  end
end
