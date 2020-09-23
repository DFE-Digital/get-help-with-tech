class Computacenter::TechsourceController < Computacenter::BaseController
  def new
    @form = BulkTechsourceForm.new
  end

  def create
    if form.valid?
      @service = ConfirmTechsourceAccountCreatedService.new(emails: form.array_of_emails)
      @service.call

      render :summary
    else
      render :new
    end
  end

private

  def form
    @form ||= BulkTechsourceForm.new(form_params)
  end

  def form_params
    params.require(:bulk_techsource_form).permit(:emails)
  end
end
