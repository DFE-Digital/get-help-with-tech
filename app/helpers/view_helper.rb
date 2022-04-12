require 'string_utils'

module ViewHelper
  include StringUtils

  DEVICE_NAMES = { laptop: 'device', router: 'router' }.freeze

  def asset_bios_password_or_unlocker(asset)
    asset.bios_unlockable? ? bios_unlocker_link(asset) : asset.bios_password
  end

  def ghwt_contact_mailto(subject: nil, label: 'COVID.TECHNOLOGY@education.gov.uk')
    mail_to_url = [
      'mailto:COVID.TECHNOLOGY@education.gov.uk',
      (subject.present? ? "subject=#{ERB::Util.url_encode(subject)}" : nil),
    ].compact.join('?')

    govuk_link_to label, mail_to_url
  end

  def govuk_button_link_to(body, url, html_options = {})
    html_options[:class] = prepend_css_class('govuk-button', html_options[:class])

    link_to(body, url, role: 'button', class: html_options[:class], 'data-module': 'govuk-button', draggable: false)
  end

  def govuk_start_button_link_to(body, url, html_options = {})
    options = {
      class: prepend_css_class('govuk-button govuk-button--start', html_options[:class]),
      role: 'button',
      data: { module: 'govuk-button' },
      draggable: false,
    }.merge(html_options.except(:class))

    link_to(url, options) do
      raw(%(#{body}
        <svg class="govuk-button__start-icon" xmlns="http://www.w3.org/2000/svg" width="17.5" height="19" viewBox="0 0 33 40" aria-hidden="true" focusable="false">
          <path fill="currentColor" d="M0 0h13l20 20-20 20H0l20-20z" />
        </svg>))
    end
  end

  def title_with_error_prefix(title, error)
    "#{t('page_titles.error_prefix') if error}#{title}"
  end

  def link_to_devices_guidance_subpage(body, slug, html_options = {}, path_options = {})
    opts = {
      subpage_slug: slug,
    }.merge(path_options)
    govuk_link_to body, devices_guidance_subpage_path(**opts), **html_options
  end

  def breadcrumbs(items)
    breadcrumbs = items.map { |k, _v| k.is_a?(Hash) ? k : { k => '' } }.inject(:merge)
    render GovukComponent::BreadcrumbsComponent.new(breadcrumbs: breadcrumbs)
  end

  def school_breadcrumbs(items:, user:, school:)
    render School::SchoolBreadcrumbsComponent.new(items: items, user: user, school: school)
  end

  def sortable_extra_mobile_data_requests_table_header(title, value = title, opts = params)
    phone_numbers = opts[:phone_numbers]

    if opts[:sort] == value.to_s
      if opts[:dir] == 'd'
        suffix = '▲'
        dir = 'a'
      else
        suffix = '▼'
        dir = 'd'
      end
      safe_join([govuk_link_to(title, mno_extra_mobile_data_requests_path(sort: value, dir: dir, phone_numbers: phone_numbers)), suffix], ' ')
    else
      govuk_link_to(title, mno_extra_mobile_data_requests_path(sort: value, phone_numbers: phone_numbers))
    end
  end

  def humanized_seconds(seconds)
    ActiveSupport::Duration.build(seconds).inspect
  end

  def humanized_token_lifetime
    humanized_seconds(Settings.sign_in_token_ttl_seconds)
  end

  def who_will_order_devices_options(show_recommendation: true)
    [
      OpenStruct.new(
        id: 'school',
        label: "Most schools and colleges will place their own orders#{' (recommended)' if show_recommendation}",
        description: 'We’ll need contact details for each school or college',
      ),
      OpenStruct.new(
        id: 'responsible_body',
        label: 'Most orders will be placed centrally',
        description: 'You’ll need to place orders for schools and colleges and give technical information for any that want to order Chromebooks',
      ),
    ]
  end

  def change_who_will_order_devices_options
    scope = 'page_titles.change_who_will_order_edit'
    [
      OpenStruct.new(
        id: 'school',
        label: t('school', scope: scope),
      ),
      OpenStruct.new(
        id: 'responsible_body',
        label: t('responsible_body', scope: scope),
      ),
    ]
  end

  def can_user_order_devices_options
    scope = 'page_titles.invite_school_user'
    [
      OpenStruct.new(
        value: '1',
        label: t('can_order_devices', scope: scope),
      ),
      OpenStruct.new(
        value: '0',
        label: t('cannot_order_devices', scope: scope),
      ),
    ]
  end

  def what_to_order_allocation_list(school_or_rb)
    DEVICE_NAMES.map { |device_type, device_name|
      quantity = school_or_rb.devices_available_to_order(device_type)
      "#{quantity} #{device_name.pluralize(quantity)}"
    }.join(' and ')
  end

  def what_to_order_availability(school)
    suffix = (school.can_order_for_specific_circumstances? ? ' for specific circumstances' : nil)

    if school.devices_available_to_order?
      string = what_to_order_allocation_list(school)

      "Order #{string}#{suffix}"
    else
      'All devices ordered'
    end
  end

  def what_to_order_state_list(school)
    DEVICE_NAMES.map { |device_type, device_name|
      quantity = school.devices_ordered(device_type)
      "#{quantity} #{device_name.pluralize(quantity)}"
    }.join(' and ')
  end

  def what_to_order_state(school)
    string = what_to_order_state_list(school)

    "You’ve ordered #{string}"
  end

  def centrally_managing_count_or_all_schools(responsible_body:)
    schools = responsible_body.schools.gias_status_open
    if responsible_body.is_ordering_for_all_schools?
      'all'
    else
      "#{schools.responsible_body_will_order_devices.count} of #{schools.count}"
    end
  end

  def chromebook_domain_label(school)
    label = Array(school.institution_type.capitalize)
    label << "or #{school.responsible_body.humanized_type}" unless school.further_education?
    label << 'email domain registered for <span class="app-no-wrap">G Suite for Education</span> (for example, &lsquo;school.co.uk&rsquo;)'
    label.join(' ').html_safe
  end

  def humanized_number(value)
    if value > 999_999
      number_to_human(value, format: '%n%u', precision: 2, significant: false, strip_insignificant_zeros: false, units: { million: 'm' })
    else
      number_with_delimiter(value)
    end
  end

  def link_to_urn_or_ukprn_otherwise_identifier(identifier)
    if School.where_urn_or_ukprn_or_provision_urn(identifier).exists?
      link_to_urn_or_ukprn(identifier)
    else
      identifier
    end
  end

  def link_to_urn_or_ukprn(identifier)
    govuk_link_to(identifier, support_school_path(identifier)) if identifier.present?
  end

  def mno_offer_details_partial(brand)
    ['shared', 'mno_offer_details', brand].join('/')
  end

  def participating_mobile_networks
    MobileNetwork.where(participation_in_pilot: 'participating').order(:brand)
  end

  def suggestion_resource_to_path(resource)
    return public_send("#{resource}_path") if resource.is_a?(Symbol)

    return resource if resource.is_a?(String) && resource.starts_with?('/')

    '/'
  end

  def html_class_name(string)
    string.to_s.parameterize.underscore
  end

private

  def bios_unlocker_link(asset)
    govuk_link_to('Download BIOS unlocker', bios_unlocker_asset_path(asset))
  end

  def prepend_css_class(css_class, current_class)
    if current_class
      current_class.prepend("#{css_class} ")
    else
      css_class
    end
  end
end
