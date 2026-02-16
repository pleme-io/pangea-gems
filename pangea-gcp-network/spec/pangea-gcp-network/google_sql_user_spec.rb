require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_sql_user"

RSpec.describe "google_sql_user" do
  it "creates a sql user with the correct parameters" do
    name = "my-user"
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
      google_sql_user(
        name: name,
        instance: instance
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_sql_user)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s)
    expect(context.instance_variable_get(:@instance)).to eq(instance)
  end
end
