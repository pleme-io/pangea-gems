require "spec_helper"
require_relative "../../lib/pangea-aws-compute/compute"

RSpec.describe PangeaAwsCompute::Compute do
  it "creates a key pair with the correct parameters" do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:key_name) { |value| @key_name = value }
    context.define_singleton_method(:public_key) { |value| @public_key = value }
    context.define_singleton_method(:tags) { |value| @tags = value }
    allow(File).to receive(:read).with("my_key.pub").and_return("ssh-rsa AAA...")

    PangeaAwsCompute::Compute.create_key_pair(context, "my-key-pair", "my_key.pub", { "Environment" => "test" })

    expect(context.instance_variable_get(:@resource_type)).to eq(:aws_key_pair)
    expect(context.instance_variable_get(:@resource_name)).to eq("my-key-pair")
    expect(context.instance_variable_get(:@key_name)).to eq("my-key-pair")
    expect(context.instance_variable_get(:@public_key)).to eq("ssh-rsa AAA...")
    expect(context.instance_variable_get(:@tags)).to eq({ "Environment" => "test" })
  end

  it "creates a launch template with the correct parameters" do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:image_id) { |value| @image_id = value }
    context.define_singleton_method(:instance_type) { |value| @instance_type = value }
    context.define_singleton_method(:key_name) { |value| @key_name = value }
    context.define_singleton_method(:vpc_security_group_ids) { |value| @vpc_security_group_ids = value }
    context.define_singleton_method(:user_data) { |value| @user_data = value }
    context.define_singleton_method(:tag_specifications) { |value| @tag_specifications = value }

    PangeaAwsCompute::Compute.create_launch_template(
      context,
      "my-launch-template",
      "ami-12345",
      "t2.micro",
      "my-key-pair",
      ["sg-12345"],
      "user_data",
      { "Environment" => "test" }
    )

    expect(context.instance_variable_get(:@resource_type)).to eq(:aws_launch_template)
    expect(context.instance_variable_get(:@resource_name)).to eq("my-launch-template")
    expect(context.instance_variable_get(:@name)).to eq("my-launch-template")
    expect(context.instance_variable_get(:@image_id)).to eq("ami-12345")
    expect(context.instance_variable_get(:@instance_type)).to eq("t2.micro")
    expect(context.instance_variable_get(:@key_name)).to eq("my-key-pair")
    expect(context.instance_variable_get(:@vpc_security_group_ids)).to eq(["sg-12345"])
    expect(context.instance_variable_get(:@user_data)).to eq("user_data")
    expect(context.instance_variable_get(:@tag_specifications)).to eq([{
      resource_type: 'instance',
      tags: { "Environment" => "test" }
    }])
  end

  it "creates an autoscaling group with the correct parameters" do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:launch_template) { |value| @launch_template = value }
    context.define_singleton_method(:desired_capacity) { |value| @desired_capacity = value }
    context.define_singleton_method(:max_size) { |value| @max_size = value }
    context.define_singleton_method(:min_size) { |value| @min_size = value }
    context.define_singleton_method(:vpc_zone_identifier) { |value| @vpc_zone_identifier = value }
    context.define_singleton_method(:tag) { |value| @tag = value }

    PangeaAwsCompute::Compute.create_autoscaling_group(
      context,
      "my-asg",
      "lt-12345",
      1,
      3,
      1,
      ["subnet-12345"],
      { "Name" => "my-asg" }
    )

    expect(context.instance_variable_get(:@resource_type)).to eq(:aws_autoscaling_group)
    expect(context.instance_variable_get(:@resource_name)).to eq("my-asg")
    expect(context.instance_variable_get(:@launch_template)).to eq({ id: "lt-12345", version: "$Latest" })
    expect(context.instance_variable_get(:@desired_capacity)).to eq(1)
    expect(context.instance_variable_get(:@max_size)).to eq(3)
    expect(context.instance_variable_get(:@min_size)).to eq(1)
    expect(context.instance_variable_get(:@vpc_zone_identifier)).to eq(["subnet-12345"])
    expect(context.instance_variable_get(:@tag)).to eq([{
      key: 'Name',
      value: "my-asg",
      propagate_at_launch: true
    }])
  end
end
