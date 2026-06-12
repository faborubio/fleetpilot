# frozen_string_literal: true

# Role model: viewers can read everything in their account, managers can also
# manage fleet resources, admins can additionally manage account settings and
# users. Tenant isolation itself happens in controllers (Current.account
# associations), not here.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    manager_or_admin?
  end

  def new?
    create?
  end

  def update?
    manager_or_admin?
  end

  def edit?
    update?
  end

  def destroy?
    manager_or_admin?
  end

  private

  def manager_or_admin?
    user.manager? || user.admin?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
