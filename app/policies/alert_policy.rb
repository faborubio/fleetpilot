# frozen_string_literal: true

class AlertPolicy < ApplicationPolicy
  def destroy?
    manager_or_admin?
  end
end
