# Tenant isolation: every domain record belongs to an Account and must only be
# reached through an account association (e.g. Current.account.vehicles).
module AccountScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account
  end
end
