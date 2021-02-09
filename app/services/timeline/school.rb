module Timeline
  class School
    FIELDS = %i[order_state status cap allocation devices_ordered].freeze

    attr_reader :school

    def initialize(school:)
      @school = school
    end

    def changesets
      @changesets ||= [school, school.device_allocations]
        .flatten
        .flat_map(&:versions)
        .sort_by(&:created_at)
        .filter { |version| (version.changeset.symbolize_keys.keys & FIELDS).size.positive? }
        .map { |v| Changeset.new(item: v.item, changeset: v.changeset) }
    end
  end
end
