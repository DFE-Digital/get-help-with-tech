class Support::AddressesController < Support::BaseController
  before_action { authorize School }

  def edit
    @school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!

    authorize @school, :update_address?
  end

  def update
    @school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!

    authorize @school, :update_address?

    if @school.update(school_params.merge(computacenter_change: 'amended'))
      flash[:success] = 'Address has been updated'
      redirect_to support_school_path(urn: @school.urn)
    else
      render :edit
    end
  end

private

  def school_params
    params.require(:school).permit(:address_1, :address_2, :address_3, :town, :county, :postcode)
  end
end
