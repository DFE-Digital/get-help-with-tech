class ExtraMobileDataSubmissionForm
  include ActiveModel::Model

  SUBMISSION_TYPES = %w[manual bulk].freeze
  attr_accessor :submission_type

  validates :submission_type, inclusion: { in: SUBMISSION_TYPES, message: I18n.t('errors.extra_mobile_data_submission_form.select_how_you_would_like_to_submit_information') }

  def manual?
    submission_type == 'manual'
  end

  def bulk?
    submission_type == 'bulk'
  end

  def self.submission_type_options
    i18n_base = 'responsible_body.extra_mobile_data_requests.new'
    SUBMISSION_TYPES.map do |st|
      OpenStruct.new(value: st, label: I18n.t("#{i18n_base}.#{st}_submission"))
    end
  end
end
