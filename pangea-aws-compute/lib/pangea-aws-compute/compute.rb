# frozen_string_literal: true

module PangeaAwsCompute
  module Compute
    def self.create_key_pair(context, name, public_key_path, tags = {})
      context.resource :aws_key_pair, name do
        key_name name
        public_key File.read(public_key_path)
        tags tags
      end
    end

    def self.create_launch_template(context, name, image_id, instance_type, key_name, vpc_security_group_ids = [], user_data = nil, tags = {})
      context.resource :aws_launch_template, name do
        name name
        image_id image_id
        instance_type instance_type
        key_name key_name
        vpc_security_group_ids vpc_security_group_ids unless vpc_security_group_ids.empty?
        user_data user_data unless user_data.nil?
        tag_specifications [{
          resource_type: 'instance',
          tags: tags
        }]
      end
    end

    def self.create_autoscaling_group(context, name, launch_template_id, desired_capacity, max_size, min_size, vpc_zone_identifier = [], tags = {})
      context.resource :aws_autoscaling_group, name do
        launch_template({ id: launch_template_id, version: '$Latest' })
        desired_capacity desired_capacity
        max_size  max_size
        min_size  min_size
        vpc_zone_identifier vpc_zone_identifier unless vpc_zone_identifier.empty?
        tag [{
          key: 'Name',
          value: tags[:Name] || name,
          propagate_at_launch: true
        }]
      end
    end
  end
end