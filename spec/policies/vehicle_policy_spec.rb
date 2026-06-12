require 'rails_helper'

RSpec.describe VehiclePolicy do
  subject(:policy) { described_class.new(user, vehicle) }

  let(:vehicle) { build_stubbed(:vehicle) }

  context "as a viewer" do
    let(:user) { build_stubbed(:user, :viewer) }

    it { is_expected.to permit_actions(%i[index show]) }
    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context "as a manager" do
    let(:user) { build_stubbed(:user, role: :manager) }

    it { is_expected.to permit_actions(%i[index show create update destroy]) }
  end

  context "as an admin" do
    let(:user) { build_stubbed(:user, :admin) }

    it { is_expected.to permit_actions(%i[index show create update destroy]) }
  end
end
