require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_project_iam_member"

RSpec.describe "google_project_iam_member" do
  it "creates a project iam member with the correct parameters" do
    name = "my-project-iam"
    role = "roles/owner"
    member = "user:test@example.com"
    project = "my-project"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:role) { |value| @role = value }
    context.define_singleton_method(:member) { |value| @member = value }
    context.define_singleton_method(:project) { |value| @project = value }

    context.instance_eval do
      google_project_iam_member(
        name: name,
        role: role,
        member: member,
        project: project
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_project_iam_member)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@role)).to eq(role)
    expect(context.instance_variable_get(:@member)).to eq(member)
    expect(context.instance_variable_get(:@project)).to eq(project)
  end
end
