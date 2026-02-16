# frozen_string_literal: true

require 'dry-struct'
require 'pangea/resources/types'

module Pangea
  module Resources
    module AWS
      module Types
        # Backup rule configuration for scheduled backups
        class BackupRuleAttributes < Dry::Struct
          transform_keys(&:to_sym)
          
          # Rule identification
          attribute :rule_name, Resources::Types::String
          
          # Target backup vault
          attribute :target_backup_vault_name, Resources::Types::String
          
          # Backup schedule (cron or rate expression)
          attribute? :schedule, Resources::Types::String.optional
          
          # Backup window (in minutes)
          attribute? :start_window, Resources::Types::Integer.default(60)
          attribute? :completion_window, Resources::Types::Integer.default(120)
          
          # Lifecycle configuration
          attribute? :lifecycle, Resources::Types::Hash.schema(
            cold_storage_after?: Resources::Types::Integer.optional,
            delete_after?: Resources::Types::Integer.optional,
            opt_in_to_archive_for_supported_resources?: Resources::Types::Bool.default(false)
          ).optional
          
          # Recovery point tags
          attribute? :recovery_point_tags, Resources::Types::Hash.map(Resources::Types::Symbol, Resources::Types::String).default({}.freeze)
          
          # Copy actions to other regions/vaults
          attribute? :copy_action, Resources::Types::Array.of(
            Resources::Types::Hash.schema(
              destination_backup_vault_arn: Resources::Types::String,
              lifecycle?: Resources::Types::Hash.schema(
                cold_storage_after?: Resources::Types::Integer.optional,
                delete_after?: Resources::Types::Integer.optional
              ).optional
            )
          ).default([].freeze)
          
          # Enable continuous backup for supported services
          attribute? :enable_continuous_backup, Resources::Types::Bool.default(false)
          
          # Custom validation
          def self.new(attributes)
            attrs = attributes.is_a?(Hash) ? attributes : {}
            instance = super(attrs)
            
            # Validate lifecycle configuration
            if instance.lifecycle
              lifecycle = instance.lifecycle
              
              # Delete after must be greater than cold storage after
              if lifecycle[:delete_after] && lifecycle[:cold_storage_after]
                if lifecycle[:delete_after] <= lifecycle[:cold_storage_after]
                  raise Dry::Struct::Error, "delete_after (#{lifecycle[:delete_after]}) must be greater than cold_storage_after (#{lifecycle[:cold_storage_after]})"
                end
              end
              
              # Cold storage minimum is 90 days
              if lifecycle[:cold_storage_after] && lifecycle[:cold_storage_after] < 90
                raise Dry::Struct::Error, "cold_storage_after must be at least 90 days"
              end
            end
            
            # Validate backup windows
            if instance.start_window && instance.start_window < 60
              raise Dry::Struct::Error, "start_window must be at least 60 minutes"
            end
            
            if instance.completion_window && instance.completion_window < 120
              raise Dry::Struct::Error, "completion_window must be at least 120 minutes" 
            end
            
            # Validate schedule format
            if instance.schedule
              unless instance.schedule.match?(/^(cron|rate)\(.+\)$/)
                raise Dry::Struct::Error, "schedule must be a valid cron() or rate() expression"
              end
            end
            
            instance
          end
        end
        
        # Advanced backup options for specific services
        class AdvancedBackupSettingAttributes < Dry::Struct
          transform_keys(&:to_sym)
          
          # Resource type (e.g., "EC2")
          attribute :resource_type, Resources::Types::String.constrained(included_in: ["EC2", "RDS", "Aurora", "DocumentDB", "Neptune", "EFS", "FSx", "Storage Gateway"])
          
          # Backup options specific to resource type
          attribute :backup_options, Resources::Types::Hash.map(Resources::Types::String, Resources::Types::String)
        end
        
        # AWS Backup Plan resource attributes with validation
        class BackupPlanAttributes < Dry::Struct
          transform_keys(&:to_sym)
          
          # Core backup plan attributes
          attribute :name, Resources::Types::String
          
          # Backup rules defining when and how backups are performed
          attribute :rule, Resources::Types::Array.of(BackupRuleAttributes).constrained(min_size: 1)
          
          # Advanced backup settings for specific resource types
          attribute? :advanced_backup_setting, Resources::Types::Array.of(AdvancedBackupSettingAttributes).default([].freeze)
          
          # Tags
          attribute :tags, Resources::Types::AwsTags.default({}.freeze)
          
          # Custom validation
          def self.new(attributes)
            attrs = attributes.is_a?(Hash) ? attributes : {}
            instance = super(attrs)
            
            # Validate unique rule names
            rule_names = instance.rule.map(&:rule_name)
            if rule_names.uniq.size != rule_names.size
              raise Dry::Struct::Error, "Backup rule names must be unique within a plan"
            end
            
            # Validate at least one rule has a schedule
            unless instance.rule.any? { |r| r.schedule }
              raise Dry::Struct::Error, "At least one backup rule must have a schedule defined"
            end
            
            instance
          end
          
          # Computed properties
          def has_lifecycle_policies?
            rule.any? { |r| r.lifecycle && !r.lifecycle.empty? }
          end
          
          def has_cross_region_copies?
            rule.any? { |r| r.copy_action && !r.copy_action.empty? }
          end
          
          def supports_continuous_backup?
            rule.any?(&:enable_continuous_backup)
          end
          
          def total_retention_days
            # Find the maximum retention period across all rules
            rule.map do |r|
              next 0 unless r.lifecycle && r.lifecycle[:delete_after]
              r.lifecycle[:delete_after]
            end.max || 0
          end
          
          def uses_cold_storage?
            rule.any? { |r| r.lifecycle && r.lifecycle[:cold_storage_after] }
          end
          
          def backup_frequency
            # Analyze schedules to determine frequency
            schedules = rule.map(&:schedule).compact
            
            if schedules.any? { |s| s.include?("rate(1 hour)") || s.include?("cron(0 * * * ?") }
              "hourly"
            elsif schedules.any? { |s| s.include?("rate(1 day)") || s.include?("rate(24 hours)") || s.include?("cron(0 0 * * ?") }
              "daily"  
            elsif schedules.any? { |s| s.include?("rate(7 days)") || s.include?("cron(0 0 ? * 1") }
              "weekly"
            elsif schedules.any? { |s| s.include?("rate(30 days)") || s.include?("cron(0 0 1 * ?") }
              "monthly"
            else
              "custom"
            end
          end
          
          def estimated_monthly_cost
            # Rough cost estimation based on backup frequency and retention
            # Note: Actual costs depend on data size and change rate
            
            base_cost = 0
            
            rule.each do |r|
              # Storage cost estimation
              frequency_multiplier = case backup_frequency
              when "hourly" then 720  # 24 * 30
              when "daily" then 30
              when "weekly" then 4
              when "monthly" then 1
              else 2 # Conservative estimate for custom
              end
              
              # Warm storage: $0.05 per GB-month
              retention_days = r.lifecycle&.dig(:delete_after) || 30
              warm_storage_months = [retention_days / 30.0, 1].max
              
              # Cold storage: $0.01 per GB-month (after 90 days)
              cold_storage_months = 0
              if r.lifecycle&.dig(:cold_storage_after)
                cold_days = retention_days - r.lifecycle[:cold_storage_after]
                cold_storage_months = [cold_days / 30.0, 0].max
                warm_storage_months -= cold_storage_months
              end
              
              # Estimate 1GB per backup (placeholder - actual size varies greatly)
              warm_cost = frequency_multiplier * warm_storage_months * 0.05
              cold_cost = frequency_multiplier * cold_storage_months * 0.01
              
              # Cross-region copy costs
              copy_cost = r.copy_action.size * frequency_multiplier * 0.02 # Transfer cost estimate
              
              base_cost += warm_cost + cold_cost + copy_cost
            end
            
            # Add restore testing cost estimate if applicable
            restore_test_cost = advanced_backup_setting.any? { |s| 
              s.backup_options["WindowsVSS"] == "enabled"
            } ? 5.0 : 0
            
            { 
              storage: base_cost.round(2), 
              restore_testing: restore_test_cost,
              total: (base_cost + restore_test_cost).round(2),
              note: "Per GB estimate - actual costs depend on data size"
            }
          end
        end
      end
    end
  end
end