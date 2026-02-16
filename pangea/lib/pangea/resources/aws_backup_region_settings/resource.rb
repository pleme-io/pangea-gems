# frozen_string_literal: true

require 'pangea/resources/base'
require 'pangea/resources/reference'

module Pangea
  module Resources
    module AWS
      # Type-safe resource function for AWS Backup Region Settings
      #
      # @param name [Symbol] The resource name
      # @param attributes [Hash] Resource attributes following AWS provider schema
      # @return [Pangea::Resources::Reference] Resource reference for chaining
      # 
      # @see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_region_settings
      #
      # @example Enable cross-region copy and advanced backup features
      #   aws_backup_region_settings(:main_region, {
      #     resource_type_opt_in_preference: {
      #       "Aurora" => true,
      #       "DocumentDB" => true,
      #       "DynamoDB" => true,
      #       "EBS" => true,
      #       "EC2" => true,
      #       "EFS" => true,
      #       "FSx" => true,
      #       "Neptune" => true,
      #       "RDS" => true,
      #       "S3" => true,
      #       "Storage Gateway" => true,
      #       "VirtualMachine" => false
      #     },
      #     resource_type_management_preference: {
      #       "DynamoDB" => true,
      #       "EFS" => true
      #     }
      #   })
      #
      # @example Minimal backup settings for development
      #   aws_backup_region_settings(:dev_region, {
      #     resource_type_opt_in_preference: {
      #       "EBS" => true,
      #       "RDS" => true
      #     }
      #   })
      def aws_backup_region_settings(name, attributes)
        transformed = Base.transform_attributes(attributes, {
          resource_type_opt_in_preference: {
            description: "Map of service opt-in preferences for backup",
            type: :map,
            required: true
          },
          resource_type_management_preference: {
            description: "Map of service management preferences",
            type: :map
          }
        })

        resource_block = resource(:aws_backup_region_settings, name, transformed)
        
        Reference.new(
          type: :aws_backup_region_settings,
          name: name,
          attributes: {
            id: "#{resource_block}.id"
          },
          resource: resource_block
        )
      end
    end
  end
end

# Auto-register this module when it's loaded
Pangea::ResourceRegistry.register(:aws, Pangea::Resources::AWS)