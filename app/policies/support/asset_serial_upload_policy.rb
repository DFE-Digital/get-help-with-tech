Support::AssetSerialUploadPolicy = Struct.new(:user, :asset_serial_upload) do
  class Scope # rubocop:disable Lint/ConstantDefinitionInBlock
    def resolve
      scope
    end
  end

  def new?
    logged_in_as_support_user?
  end

  def create?
    logged_in_as_support_user?
  end

private

  def logged_in_as_support_user?
    user.present? && user.is_support?
  end
end
