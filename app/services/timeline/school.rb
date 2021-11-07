module Timeline
  class School
    FIELDS = %i[
      order_state
      circumstances_laptops
      circumstances_routers
      over_order_reclaimed_laptops
      over_order_reclaimed_routers
      status
      raw_laptop_allocation
      raw_laptops_ordered
      raw_router_allocation
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
