class DataStage::ResponsibleBody
  RB_NAME_MAP = {
    'Bristol, City of' => 'City of Bristol',
    'Dorset' => 'Dorset Council',
    'Herefordshire, County of' => 'Herefordshire',
    'Kingston upon Hull, City of' => 'Kingston upon Hull',
  }.freeze

  def self.find_by_name(responsible_body_name)
    ::ResponsibleBody.find_by(name: translated(responsible_body_name))
  end

  def self.translated(responsible_body_name)
    RB_NAME_MAP.fetch(responsible_body_name, responsible_body_name)
  end
end
