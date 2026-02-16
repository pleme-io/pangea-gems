require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_sql_database"

RSpec.describe "google_sql_database" do
  it "creates a sql database with the correct parameters" do
    name = "my-database"
    instance = "my-instance"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:instance) { |value| @instance = value }

    context.instance_eval do
      google_sql_database(
        name: name,
        instance: instance
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_sql_database)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s)
    expect(context.instance_variable_get(:@instance)).to eq(instance)
  end
end
