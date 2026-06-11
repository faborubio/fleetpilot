require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "POST /registration" do
    it "creates the account with its first admin user and signs them in" do
      expect {
        post registration_path, params: { registration: {
          account_name: "Acme Fleet Co",
          email_address: "owner@acme.test",
          password: "password123",
          password_confirmation: "password123"
        } }
      }.to change(Account, :count).by(1).and change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(User.last).to have_attributes(role: "admin", account: Account.last)

      follow_redirect!
      expect(response.body).to include("Acme Fleet Co")
    end

    it "creates nothing when validation fails" do
      expect {
        post registration_path, params: { registration: {
          account_name: "", email_address: "owner@acme.test", password: "password123",
          password_confirmation: "password123"
        } }
      }.to not_change(Account, :count).and not_change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "rolls the account back when the user is invalid" do
      expect {
        post registration_path, params: { registration: {
          account_name: "Acme Fleet Co", email_address: "bad", password: "password123",
          password_confirmation: "password123"
        } }
      }.to not_change(Account, :count).and not_change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
