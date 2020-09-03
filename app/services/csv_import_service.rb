class CsvImportService
  def self.import!(csv_data_file)
    importer = CsvDataFileImporter.new(csv_data_file: csv_data_file)
    importer.import!
    { successes: importer.successes, failures: importer.failures }
  end
end
