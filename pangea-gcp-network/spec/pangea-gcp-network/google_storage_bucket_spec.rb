require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_storage_bucket"

RSpec.describe "google_storage_bucket" do
  it "creates a storage bucket with the correct parameters" do
    name = "my-bucket"
    bucket_name = "my-bucket-name"
    location = "US"
    force_destroy = true
    uniform_bucket_level_access = true
    website = {
      main_page_suffix: "index.html"
    }
    storage_class = "STANDARD"
    versioning = {
      enabled: true
    }
    lifecycle_rule = {
      action: {
        type: "Delete"
      },
      condition: {
        age: 30
      }
    }

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:location) { |value| @location = value }
    context.define_singleton_method(:force_destroy) { |value| @force_destroy = value }
    context.define_singleton_method(:uniform_bucket_level_access) { |value| @uniform_bucket_level_access = value }
    context.define_singleton_method(:website) { |&block| @website = block }
    context.define_singleton_method(:storage_class) { |value| @storage_class = value }
    context.define_singleton_method(:versioning) { |&block| @versioning = block }
    context.define_singleton_method(:lifecycle_rule) { |&block| @lifecycle_rule = block }

    context.instance_eval do
      google_storage_bucket(
        name: name,
        bucket_name: bucket_name,
        location: location,
        force_destroy: force_destroy,
        uniform_bucket_level_access: uniform_bucket_level_access,
        website: website,
        storage_class: storage_class,
        versioning: versioning,
        lifecycle_rule: lifecycle_rule
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_storage_bucket)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(bucket_name)
    expect(context.instance_variable_get(:@location)).to eq(location)
    expect(context.instance_variable_get(:@force_destroy)).to eq(force_destroy)
    expect(context.instance_variable_get(:@uniform_bucket_level_access)).to eq(uniform_bucket_level_access)
    expect(context.instance_variable_get(:@storage_class)).to eq(storage_class)
  end
end
