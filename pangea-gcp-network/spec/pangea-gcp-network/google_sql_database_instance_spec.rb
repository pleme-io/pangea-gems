require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_sql_database_instance"

RSpec.describe "google_sql_database_instance" do
  it "creates a sql database instance with the correct parameters" do
    name = "my-instance"
    database_version = "POSTGRES_13"
    region = "us-central1"
    settings = {
      tier: "db-g1-small",
      ip_configuration: {
        private_network: "my-network"
      }
    }
    depends_on = ["my-dependency"]

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:database_version) { |value| @database_version = value }
    context.define_singleton_method(:region) { |value| @region = value }
    context.define_singleton_method(:settings) { |&block| @settings = block }
    context.define_singleton_method(:depends_on) { |value| @depends_on = value }

    context.instance_eval do
      google_sql_database_instance(
        name: name,
        database_version: database_version,
        region: region,
        settings: settings,
        depends_on: depends_on
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_sql_database_instance)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@database_version)).to eq(database_version)
    expect(context.instance_variable_get(:@region)).to eq(region)
    expect(context.instance_variable_get(:@depends_on)).to eq(depends_on)
  end
end
