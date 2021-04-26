module SchoolType
  extend ActiveSupport::Concern

  included do
    enum phase: {
      primary: 'primary',
      secondary: 'secondary',
      all_through: 'all_through',
      sixteen_plus: 'sixteen_plus',
      nursery: 'nursery',
      phase_not_applicable: 'phase_not_applicable',
    }

    enum establishment_type: {
      academy: 'academy',
      free: 'free',
      local_authority: 'local_authority',
      special: 'special',
      other_type: 'other_type',
      la_funded_place: 'la_funded_place',
      social_care_provision: 'social_care_provision',
    }, _suffix: true

    def human_for_school_type
      I18n.t(school_type, scope: %i[activerecord attributes school school_type], default: [:other])
    end

    def school_type
      if special_establishment_type?
        'special_school'
      elsif phase && !phase_not_applicable?
        "#{phase}_school"
      end
    end
  end
end
