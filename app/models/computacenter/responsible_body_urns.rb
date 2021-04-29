module Computacenter::ResponsibleBodyUrns
  module ClassMethods
    def requiring_a_new_computacenter_reference
      gias_status_open
        .where(computacenter_change: %w[new amended]).or(gias_status_open.where(computacenter_reference: nil))
        .includes(:schools)
        .distinct
    end

    def find_by_computacenter_urn!(cc_urn)
      our_identifier = convert_computacenter_urn(cc_urn)
      # given URNs starting with 't' are for Trusts
      if cc_urn.starts_with?('t')
        find_by_companies_house_number!(our_identifier)
      else
        # If it's not a Trust, assume it's a school
        find_by_gias_id!(our_identifier)
      end
    end

    # Computacenter's list of RBs has type-dependent prefixes for URNs
    def convert_computacenter_urn(cc_urn)
      # Trusts start with 't'
      if cc_urn.starts_with?('t')
        # take off the leading 't' and pad it to 8 chars with leading zeroes
        cc_urn[1..-1].rjust(8, '0')
      elsif cc_urn.starts_with?('LEA')
        # just remove the leading 'LEA'
        cc_urn[3..-1]
      else
        # if we can't convert it, just return the given string
        # - that way we can use it as-is in queries and it will raise
        # an ActiveRecord::RecordNotFound error. If we'd returned nil, we'd
        # get spurious matches
        cc_urn
      end
    end
  end

  module InstanceMethods
    def computacenter_identifier
      case type
      when 'LocalAuthority'
        "LEA#{gias_id}"
      when 'Trust'
        if companies_house_number.blank?
          ''
        else
          "t#{companies_house_number.to_i}"
        end
      when 'FurtherEducationCollege'
        # potential n+1
        if schools.first&.ukprn
          "FE#{schools.first&.ukprn}"
        else
          ''
        end
      when 'DfE'
        'DfE'
      end
    end

    def computacenter_name
      case type
      when 'LocalAuthority'
        local_authority_official_name
      when 'Trust', 'FurtherEducationCollege'
        name
      when 'DfE'
        'Department for Education'
      end
    end
  end
end
