module Timeline
  class Changeset
    attr_reader :item, :changeset

    def initialize(item:, changeset:)
      @item = item
      @changeset = changeset
    end

    def updated_at
      changeset[:updated_at][1]
    end

    def changes
      @changes ||= changeset.except(:updated_at, :id, :created_at, :school_id, :device_type)
    end

    delegate :size, to: :changes

    def item_type
      if item.respond_to?(:device_type)
        item.device_type
      else
        item.class.base_class
      end
    end
  end
end
