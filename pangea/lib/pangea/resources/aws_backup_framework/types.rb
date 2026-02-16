# frozen_string_literal: true

require 'pangea/resources/types'

module Pangea
  module Resources
    module AWS
      module Types
        # Input parameter for backup framework controls
        class InputParameter < Dry::Struct
        # Parameter name (e.g., "requiredFrequencyUnit", "requiredRetentionDays")
        attribute :parameter_name, Resources::Types::String
        
        # Parameter value as string
        attribute :parameter_value, Resources::Types::String
        
        # Check if this is a frequency unit parameter
        def is_frequency_unit?
          parameter_name == "requiredFrequencyUnit"
        end
        
        # Check if this is a frequency value parameter
        def is_frequency_value?
          parameter_name == "requiredFrequencyValue"
        end
        
        # Check if this is a retention parameter
        def is_retention_parameter?
          parameter_name.include?("retention") || parameter_name.include?("Retention")
        end
        
        # Get parameter as integer if numeric
        def parameter_value_as_int
          return nil unless parameter_value.match?(/\A\d+\z/)
          parameter_value.to_i
        end
        end

      # Control scope for backup framework
      class ControlScope < Dry::Struct
        # Resource types this control applies to (optional)
        attribute :compliance_resource_types, Resources::Types::Array.of(Types::String).optional
        
        # Tags to filter resources (optional)
        attribute :tags, Resources::Types::Hash.optional
        
        # Check if scope applies to specific resource type
        def applies_to_resource_type?(resource_type)
          return true if compliance_resource_types.nil?
          compliance_resource_types.include?(resource_type)
        end
        
        # Check if scope has tag filtering
        def has_tag_filtering?
          !tags.nil? && tags.any?
        end
        
        # Get resource types as formatted string
        def resource_types_summary
          return "All resource types" if compliance_resource_types.nil? || compliance_resource_types.empty?
          compliance_resource_types.join(", ")
        end
      end

      # Backup framework control definition
      class FrameworkControl < Dry::Struct
        # Control name (AWS predefined control name)
        attribute :name, Resources::Types::String
        
        # Input parameters for the control
        attribute :input_parameter, Resources::Types::Array.of(InputParameter).default([].freeze)
        
        # Scope for the control (optional)
        attribute? :scope, ControlScope.optional
        
        # Validate control name format
        def self.new(attributes = {})
          attrs = super(attributes.transform_keys(&:to_sym))
          
          # Validate control name is a valid AWS Backup control
          valid_controls = [
            "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
            "BACKUP_PLAN_MIN_FREQUENCY_AND_MIN_RETENTION_CHECK",
            "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED",
            "BACKUP_LAST_RECOVERY_POINT_CREATED",
            "BACKUP_RESOURCES_PROTECTED_BY_BACKUP_PLAN",
            "BACKUP_RECOVERY_POINT_ENCRYPTED"
          ]
          
          unless valid_controls.include?(attrs.name)
            raise Dry::Struct::Error, "Invalid control name '#{attrs.name}'. Must be one of: #{valid_controls.join(', ')}"
          end
          
          attrs
        end
        
        # Check if this is a frequency/retention control
        def is_frequency_control?
          name.include?("FREQUENCY") || name.include?("RETENTION")
        end
        
        # Check if this is an encryption control
        def is_encryption_control?
          name.include?("ENCRYPTED")
        end
        
        # Check if this is a deletion protection control
        def is_deletion_protection_control?
          name.include?("DELETION_DISABLED")
        end
        
        # Check if control has resource type filtering
        def has_resource_filtering?
          scope&.compliance_resource_types&.any?
        end
        
        # Get frequency parameters if this is a frequency control
        def frequency_parameters
          return {} unless is_frequency_control?
          
          params = {}
          input_parameter.each do |param|
            case param.parameter_name
            when "requiredFrequencyUnit"
              params[:unit] = param.parameter_value
            when "requiredFrequencyValue"
              params[:value] = param.parameter_value_as_int
            when "requiredRetentionDays"
              params[:retention_days] = param.parameter_value_as_int
            end
          end
          
          params
        end
        
        # Get control summary
        def control_summary
          parts = [name.split("_").map(&:capitalize).join(" ")]
          parts << "(#{scope.resource_types_summary})" if scope
          parts.join(" ")
        end
      end

      # Type-safe attributes for AWS Backup Framework resources
      class BackupFrameworkAttributes < Dry::Struct
        # Framework name (required, 1-256 characters)
        attribute :name, Resources::Types::String
        
        # Framework description (optional)
        attribute :description, Resources::Types::String.optional
        
        # Controls for the framework
        attribute :control, Resources::Types::Array.of(FrameworkControl).default([].freeze)
        
        # Tags to apply to the framework
        attribute :tags, Resources::Types::AwsTags.default({}.freeze)

        # Custom validation
        def self.new(attributes = {})
          attrs = super(attributes.transform_keys(&:to_sym))
          
          # Validate framework name
          if attrs.name.length < 1 || attrs.name.length > 256
            raise Dry::Struct::Error, "Framework name must be 1-256 characters"
          end
          
          unless attrs.name.match?(/\A[a-zA-Z0-9_\-\.]+\z/)
            raise Dry::Struct::Error, "Framework name contains invalid characters (alphanumeric, hyphens, underscores, dots only)"
          end
          
          # Validate description length if provided
          if attrs.description && attrs.description.length > 1024
            raise Dry::Struct::Error, "Framework description cannot exceed 1024 characters"
          end
          
          # Validate at least one control is provided
          if attrs.control.empty?
            raise Dry::Struct::Error, "Framework must have at least one control"
          end
          
          # Validate control names are unique
          control_names = attrs.control.map(&:name)
          duplicates = control_names.group_by(&:itself).select { |_, v| v.size > 1 }.keys
          unless duplicates.empty?
            raise Dry::Struct::Error, "Duplicate control names found: #{duplicates.join(', ')}"
          end
          
          attrs
        end

        # Check if framework has frequency controls
        def has_frequency_controls?
          control.any?(&:is_frequency_control?)
        end

        # Check if framework has encryption controls
        def has_encryption_controls?
          control.any?(&:is_encryption_control?)
        end

        # Check if framework has deletion protection controls
        def has_deletion_protection_controls?
          control.any?(&:is_deletion_protection_control?)
        end

        # Get all resource types covered by framework
        def covered_resource_types
          types = control.flat_map do |ctrl|
            ctrl.scope&.compliance_resource_types || []
          end.uniq
          
          types.empty? ? ["All resource types"] : types
        end

        # Check if framework applies to specific resource type
        def applies_to_resource_type?(resource_type)
          control.any? { |ctrl| ctrl.scope&.applies_to_resource_type?(resource_type) }
        end

        # Get framework complexity score (based on number and type of controls)
        def complexity_score
          base_score = control.count * 10
          
          # Add complexity for different control types
          base_score += 20 if has_frequency_controls?
          base_score += 15 if has_encryption_controls?
          base_score += 10 if has_deletion_protection_controls?
          
          # Add complexity for resource filtering
          base_score += control.count { |ctrl| ctrl.has_resource_filtering? } * 5
          
          base_score
        end

        # Check if this is a compliance-focused framework
        def is_compliance_framework?
          has_frequency_controls? && has_encryption_controls?
        end

        # Check if this is a basic protection framework
        def is_basic_framework?
          control.count <= 2 && !has_encryption_controls?
        end

        # Get estimated monthly cost based on controls and resources
        def estimated_monthly_cost_usd
          base_cost = 2.0  # Base cost per framework
          
          # Cost per control
          base_cost += control.count * 0.50
          
          # Additional cost for complex controls
          base_cost += 1.0 if has_frequency_controls?
          base_cost += 0.50 if has_encryption_controls?
          
          # Estimated resource evaluation costs
          resource_types = covered_resource_types.reject { |t| t == "All resource types" }
          if resource_types.any?
            base_cost += resource_types.count * 0.25
          else
            base_cost += 2.0  # All resource types
          end
          
          base_cost.round(2)
        end

        # Get recommended evaluation frequency
        def recommended_evaluation_frequency
          if has_frequency_controls? || has_encryption_controls?
            "daily"
          elsif has_deletion_protection_controls?
            "weekly"
          else
            "monthly"
          end
        end

        # Generate framework summary
        def framework_summary
          features = []
          features << "Frequency controls" if has_frequency_controls?
          features << "Encryption controls" if has_encryption_controls?
          features << "Deletion protection" if has_deletion_protection_controls?
          features << "#{self.control.count} controls"
          
          "#{self.name}: #{features.join(', ')}"
        end
      end

      # Common Backup Framework configurations
      module BackupFrameworkConfigs
        # Basic compliance framework
        def self.basic_compliance(framework_name:)
          {
            name: framework_name,
            description: "Basic compliance framework for backup policies",
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
                input_parameter: [
                  {
                    parameter_name: "requiredFrequencyUnit",
                    parameter_value: "days"
                  },
                  {
                    parameter_name: "requiredFrequencyValue", 
                    parameter_value: "1"
                  }
                ]
              },
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
                input_parameter: []
              }
            ],
            tags: {
              Purpose: "compliance",
              Complexity: "basic"
            }
          }
        end

        # Production compliance framework
        def self.production_compliance(framework_name:, resource_types: ["EBS", "RDS"])
          {
            name: framework_name,
            description: "Production compliance framework with comprehensive controls",
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
                input_parameter: [
                  {
                    parameter_name: "requiredFrequencyUnit",
                    parameter_value: "hours"
                  },
                  {
                    parameter_name: "requiredFrequencyValue",
                    parameter_value: "24"
                  }
                ],
                scope: {
                  compliance_resource_types: resource_types,
                  tags: {
                    "Environment" => "production"
                  }
                }
              },
              {
                name: "BACKUP_PLAN_MIN_FREQUENCY_AND_MIN_RETENTION_CHECK",
                input_parameter: [
                  {
                    parameter_name: "requiredFrequencyUnit",
                    parameter_value: "days"
                  },
                  {
                    parameter_name: "requiredRetentionDays",
                    parameter_value: "30"
                  }
                ]
              },
              {
                name: "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED",
                input_parameter: []
              },
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
                input_parameter: []
              }
            ],
            tags: {
              Purpose: "production-compliance",
              Environment: "production",
              Complexity: "comprehensive"
            }
          }
        end

        # Database-focused framework
        def self.database_protection(framework_name:)
          {
            name: framework_name,
            description: "Framework focused on database backup compliance",
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
                input_parameter: [
                  {
                    parameter_name: "requiredFrequencyUnit",
                    parameter_value: "hours"
                  },
                  {
                    parameter_name: "requiredFrequencyValue",
                    parameter_value: "12"
                  }
                ],
                scope: {
                  compliance_resource_types: ["RDS", "DynamoDB"],
                  tags: {
                    "DataTier" => "database"
                  }
                }
              },
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
                scope: {
                  compliance_resource_types: ["RDS", "DynamoDB"]
                }
              },
              {
                name: "BACKUP_RESOURCES_PROTECTED_BY_BACKUP_PLAN",
                scope: {
                  compliance_resource_types: ["RDS", "DynamoDB"]
                }
              }
            ],
            tags: {
              Purpose: "database-protection",
              DataTier: "database"
            }
          }
        end

        # Development environment framework
        def self.development_basic(framework_name:)
          {
            name: framework_name,
            description: "Basic framework for development environment backups",
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
                input_parameter: [
                  {
                    parameter_name: "requiredFrequencyUnit",
                    parameter_value: "days"
                  },
                  {
                    parameter_name: "requiredFrequencyValue",
                    parameter_value: "7"
                  }
                ],
                scope: {
                  tags: {
                    "Environment" => "development"
                  }
                }
              }
            ],
            tags: {
              Purpose: "development",
              Environment: "development",
              CostOptimized: "true"
            }
          }
        end
      end
    end
  end
end
