# frozen_string_literal: true

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/aws_backup_framework/types'
require 'pangea/resource_registry'

module Pangea
  module Resources
    module AWS
      # Create an AWS Backup Framework with type-safe attributes
      #
      # @param name [Symbol] The resource name
      # @param attributes [Hash] Framework attributes
      # @return [ResourceReference] Reference object with outputs and computed properties
      #
      # @example Basic compliance framework
      #   framework = aws_backup_framework(:basic_compliance, {
      #     name: "BasicComplianceFramework",
      #     description: "Basic compliance framework for backup policies",
      #     control: [
      #       {
      #         name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
      #         input_parameter: [
      #           {
      #             parameter_name: "requiredFrequencyUnit",
      #             parameter_value: "days"
      #           },
      #           {
      #             parameter_name: "requiredFrequencyValue",
      #             parameter_value: "1"
      #           }
      #         ]
      #       }
      #     ]
      #   })
      #
      # @example Production compliance framework with resource filtering
      #   framework = aws_backup_framework(:production_compliance, {
      #     name: "ProductionComplianceFramework",
      #     description: "Comprehensive compliance framework for production",
      #     control: [
      #       {
      #         name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
      #         input_parameter: [
      #           {
      #             parameter_name: "requiredFrequencyUnit",
      #             parameter_value: "hours"
      #           },
      #           {
      #             parameter_name: "requiredFrequencyValue",
      #             parameter_value: "24"
      #           }
      #         ],
      #         scope: {
      #           compliance_resource_types: ["EBS", "RDS"],
      #           tags: {
      #             "Environment" => "production"
      #           }
      #         }
      #       },
      #       {
      #         name: "BACKUP_PLAN_MIN_FREQUENCY_AND_MIN_RETENTION_CHECK",
      #         input_parameter: [
      #           {
      #             parameter_name: "requiredRetentionDays",
      #             parameter_value: "30"
      #           }
      #         ]
      #       },
      #       {
      #         name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
      #       }
      #     ],
      #     tags: {
      #       Environment: "production",
      #       ComplianceRequired: "true"
      #     }
      #   })
      def aws_backup_framework(name, attributes = {})
        # Validate attributes using dry-struct
        framework_attrs = Types::BackupFrameworkAttributes.new(attributes)
        
        # Generate terraform resource block via terraform-synthesizer
        resource(:aws_backup_framework, name) do
          # Required attributes
          self.name framework_attrs.name
          description framework_attrs.description if framework_attrs.description
          
          # Framework controls
          framework_attrs.control.each do |ctrl|
            control do
              self.name ctrl.name
              
              # Input parameters
              if ctrl.input_parameter.any?
                ctrl.input_parameter.each do |param|
                  input_parameter do
                    parameter_name param.parameter_name
                    parameter_value param.parameter_value
                  end
                end
              end
              
              # Control scope
              if ctrl.scope
                scope do
                  if ctrl.scope.compliance_resource_types
                    compliance_resource_types ctrl.scope.compliance_resource_types
                  end
                  
                  if ctrl.scope.tags
                    tags do
                      ctrl.scope.tags.each do |key, value|
                        public_send(key, value)
                      end
                    end
                  end
                end
              end
            end
          end
          
          # Apply tags if present
          if framework_attrs.tags.any?
            tags do
              framework_attrs.tags.each do |key, value|
                public_send(key, value)
              end
            end
          end
        end
        
        # Return resource reference with available outputs
        ResourceReference.new(
          type: 'aws_backup_framework',
          name: name,
          resource_attributes: framework_attrs.to_h,
          outputs: {
            id: "${aws_backup_framework.#{name}.id}",
            arn: "${aws_backup_framework.#{name}.arn}",
            name: "${aws_backup_framework.#{name}.name}",
            status: "${aws_backup_framework.#{name}.status}",
            tags_all: "${aws_backup_framework.#{name}.tags_all}",
            creation_time: "${aws_backup_framework.#{name}.creation_time}",
            deployment_status: "${aws_backup_framework.#{name}.deployment_status}",
            framework_description: "${aws_backup_framework.#{name}.framework_description}",
            number_of_controls: "${aws_backup_framework.#{name}.number_of_controls}"
          },
          computed_properties: {
            has_frequency_controls: framework_attrs.has_frequency_controls?,
            has_encryption_controls: framework_attrs.has_encryption_controls?,
            has_deletion_protection_controls: framework_attrs.has_deletion_protection_controls?,
            covered_resource_types: framework_attrs.covered_resource_types,
            complexity_score: framework_attrs.complexity_score,
            is_compliance_framework: framework_attrs.is_compliance_framework?,
            is_basic_framework: framework_attrs.is_basic_framework?,
            estimated_monthly_cost_usd: framework_attrs.estimated_monthly_cost_usd,
            recommended_evaluation_frequency: framework_attrs.recommended_evaluation_frequency,
            framework_summary: framework_attrs.framework_summary
          }
        )
      end
    end
  end
end

# Auto-register this module when it's loaded
Pangea::ResourceRegistry.register(:aws, Pangea::Resources::AWS)