# Form object for the signup flow: creates the Account and its first admin
# user in one transaction.
class Registration
  include ActiveModel::Model

  attr_accessor :account_name, :email_address, :password, :password_confirmation
  attr_reader :account, :user

  validates :account_name, presence: true
  validates :email_address, presence: true

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @account = Account.create!(name: account_name)
      @user = @account.users.create!(
        email_address: email_address,
        password: password,
        password_confirmation: password_confirmation,
        role: :admin
      )
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.each { |error| errors.add(error.attribute, error.message) }
    false
  end
end
