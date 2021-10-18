module Timeline
  class School
    FIELDS = %i[
      order_state
      status
      raw_laptop_allocation
      raw_laptop_cap
      raw_laptops_ordered
      raw_router_allocation
      raw_router_cap
      raw_routers_ordered
      responsible_body_id
    ].freeze

    attr_reader :school

    def initialize(school:)
      @school = school
    end

    def changesets
      @changesets ||= [school]
                        .flat_map(&:versions)
                        .sort_by(&:created_at)
                        .filter { |version| (version.changeset.symbolize_keys.keys & FIELDS).size.positive? }
                        .map { |v| Changeset.new(item: v.item, changeset: v.changeset) }
    end
  end
end
