require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_secret_manager_secret_iam_member"

RSpec.describe "google_secret_manager_secret_iam_member" do
  it "creates a secret manager secret iam member with the correct parameters" do
    name = "my-secret-iam"
    secret_id = "my-secret-id"
    role = "roles/secretmanager.secretAccessor"
    member = "user:test@example.com"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:secret_id) { |value| @secret_id = value }
    context.define_singleton_method(:role) { |value| @role = value }
    context.define_singleton_method(:member) { |value| @member = value }

    context.instance_eval do
      google_secret_manager_secret_iam_member(
        name: name,
        secret_id: secret_id,
        role: role,
        member: member
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_secret_manager_secret_iam_member)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@secret_id)).to eq(secret_id)
    expect(context.instance_variable_get(:@role)).to eq(role)
    expect(context.instance_variable_get(:@member)).to eq(member)
  end
end
