class School::DetailsController < School::BaseController
  def show
    @school_summary = details_rows
  end

private

  def details_rows
    [
      {
        key: 'Provisional allocation',
        value: t(:n_devices, scope: %w[school details], count: @school.std_device_allocation&.allocation.to_i),
      },
      {
        key: 'Will your school need to order Chromebooks?',
        value: @school.preorder_information&.will_need_chromebooks.to_s.capitalize,
      },
    ]
  end
end
