require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_storage_bucket_iam_member"

RSpec.describe "google_storage_bucket_iam_member" do
  it "creates a storage bucket iam member with the correct parameters" do
    name = "my-bucket-iam"
    bucket = "my-bucket"
    role = "roles/storage.objectViewer"
    member = "user:test@example.com"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:bucket) { |value| @bucket = value }
    context.define_singleton_method(:role) { |value| @role = value }
    context.define_singleton_method(:member) { |value| @member = value }

    context.instance_eval do
      google_storage_bucket_iam_member(
        name: name,
        bucket: bucket,
        role: role,
        member: member
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_storage_bucket_iam_member)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@bucket)).to eq(bucket)
    expect(context.instance_variable_get(:@role)).to eq(role)
    expect(context.instance_variable_get(:@member)).to eq(member)
  end
end
