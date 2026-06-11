# Minimal matchers for policy specs.
RSpec::Matchers.define :permit_actions do |actions|
  match do |policy|
    actions.all? { |action| policy.public_send(:"#{action}?") }
  end
  failure_message do |policy|
    denied = actions.reject { |action| policy.public_send(:"#{action}?") }
    "expected #{policy.class} to permit #{denied.join(', ')}"
  end
end

RSpec::Matchers.define :forbid_actions do |actions|
  match do |policy|
    actions.none? { |action| policy.public_send(:"#{action}?") }
  end
  failure_message do |policy|
    allowed = actions.select { |action| policy.public_send(:"#{action}?") }
    "expected #{policy.class} to forbid #{allowed.join(', ')}"
  end
end
