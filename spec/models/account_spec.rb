require 'rails_helper'

RSpec.describe Account, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:users).dependent(:destroy) }
  it { is_expected.to have_many(:vehicles).dependent(:destroy) }
  it { is_expected.to have_many(:drivers).dependent(:destroy) }
  it { is_expected.to have_many(:assignments).dependent(:destroy) }
end
