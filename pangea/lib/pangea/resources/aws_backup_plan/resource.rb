# frozen_string_literal: true

require 'pangea/resources/base'
require 'pangea/resources/reference'
require_relative 'types'

module Pangea
  module Resources
    module AWS
      # Creates an AWS Backup Plan for automated backup management
      #
      # @param name [Symbol] The unique name for this resource instance
      # @param attributes [Hash] Backup plan configuration
      # @return [ResourceReference] Reference object with backup plan outputs
      #
      # @example Daily backup with 30-day retention
      #   backup_plan = aws_backup_plan(:daily_backups, {
      #     name: "daily-backup-plan",
      #     rule: [{
      #       rule_name: "DailyRule",
      #       target_backup_vault_name: vault_ref.name,
      #       schedule: "cron(0 2 * * ? *)",
      #       lifecycle: { delete_after: 30 }
      #     }]
      #   })
      #
      # @example Compliance backup with cross-region copy
      #   backup_plan = aws_backup_plan(:compliance, {
      #     name: "compliance-backup-plan",
      #     rule: [{
      #       rule_name: "HourlyBackups",
      #       target_backup_vault_name: "primary-vault",
      #       schedule: "rate(1 hour)",
      #       lifecycle: { 
      #         cold_storage_after: 90,
      #         delete_after: 2555 # 7 years
      #       },
      #       copy_action: [{
      #         destination_backup_vault_arn: dr_vault.arn,
      #         lifecycle: { delete_after: 365 }
      #       }]
      #     }]
      #   })
      #
      # @example Multi-tier backup strategy
      #   backup_plan = aws_backup_plan(:tiered, {
      #     name: "tiered-backup-strategy",
      #     rule: [
      #       {
      #         rule_name: "FrequentBackups",
      #         target_backup_vault_name: "hot-vault",
      #         schedule: "rate(6 hours)",
      #         lifecycle: { delete_after: 7 }
      #       },
      #       {
      #         rule_name: "DailyBackups", 
      #         target_backup_vault_name: "warm-vault",
      #         schedule: "cron(0 3 * * ? *)",
      #         lifecycle: { delete_after: 30 }
      #       },
      #       {
      #         rule_name: "MonthlyArchive",
      #         target_backup_vault_name: "archive-vault",
      #         schedule: "cron(0 3 1 * ? *)",
      #         lifecycle: {
      #           cold_storage_after: 90,
      #           delete_after: 2555
      #         }
      #       }
      #     ]
      #   })
      def aws_backup_plan(name, attributes = {})
        # Validate and transform attributes
        plan_attrs = AWS::Types::Types::BackupPlanAttributes.new(attributes)
        
        # Create backup plan resource
        resource(:aws_backup_plan, name) do
          backup_plan do
            backup_plan_name plan_attrs.name
            
            # Process each backup rule
            plan_attrs.rule.each do |rule|
              rule do
                rule_name rule.rule_name
                target_backup_vault_name rule.target_backup_vault_name
                
                # Schedule configuration
                schedule rule.schedule if rule.schedule
                start_window_minutes rule.start_window if rule.start_window != 60
                completion_window_minutes rule.completion_window if rule.completion_window != 120
                
                # Lifecycle configuration
                if rule.lifecycle && !rule.lifecycle.empty?
                  lifecycle do
                    cold_storage_after_days rule.lifecycle[:cold_storage_after] if rule.lifecycle[:cold_storage_after]
                    delete_after_days rule.lifecycle[:delete_after] if rule.lifecycle[:delete_after]
                    opt_in_to_archive_for_supported_resources rule.lifecycle[:opt_in_to_archive_for_supported_resources] if rule.lifecycle[:opt_in_to_archive_for_supported_resources]
                  end
                end
                
                # Recovery point tags
                if rule.recovery_point_tags.any?
                  recovery_point_tags do
                    rule.recovery_point_tags.each { |key, value| public_send(key, value) }
                  end
                end
                
                # Copy actions for cross-region/vault copies
                if rule.copy_action && rule.copy_action.any?
                  rule.copy_action.each do |copy|
                    copy_action do
                      destination_backup_vault_arn copy[:destination_backup_vault_arn]
                      
                      if copy[:lifecycle] && !copy[:lifecycle].empty?
                        lifecycle do
                          cold_storage_after_days copy[:lifecycle][:cold_storage_after] if copy[:lifecycle][:cold_storage_after]
                          delete_after_days copy[:lifecycle][:delete_after] if copy[:lifecycle][:delete_after]
                        end
                      end
                    end
                  end
                end
                
                # Enable continuous backup if specified
                enable_continuous_backup rule.enable_continuous_backup if rule.enable_continuous_backup
              end
            end
            
            # Advanced backup settings
            if plan_attrs.advanced_backup_setting.any?
              plan_attrs.advanced_backup_setting.each do |setting|
                advanced_backup_setting do
                  resource_type setting.resource_type
                  backup_options setting.backup_options
                end
              end
            end
          end
          
          # Tags
          if plan_attrs.tags.any?
            tags do
              plan_attrs.tags.each { |key, value| public_send(key, value) }
            end
          end
        end
        
        # Return reference with backup plan outputs
        ref = ResourceReference.new(
          type: 'aws_backup_plan',
          name: name,
          resource_attributes: plan_attrs.to_h,
          outputs: {
            # Core identifiers
            id: "${aws_backup_plan.#{name}.id}",
            arn: "${aws_backup_plan.#{name}.arn}",
            version: "${aws_backup_plan.#{name}.version}",
            
            # Plan details
            name: plan_attrs.name,
            tags_all: "${aws_backup_plan.#{name}.tags_all}",
            
            # Computed from attributes
            rule_count: plan_attrs.rule.size,
            has_lifecycle_policies: plan_attrs.has_lifecycle_policies?,
            has_cross_region_copies: plan_attrs.has_cross_region_copies?
          }
        )
        
        # Add computed properties via method delegation
        ref.define_singleton_method(:has_lifecycle_policies?) { plan_attrs.has_lifecycle_policies? }
        ref.define_singleton_method(:has_cross_region_copies?) { plan_attrs.has_cross_region_copies? }
        ref.define_singleton_method(:supports_continuous_backup?) { plan_attrs.supports_continuous_backup? }
        ref.define_singleton_method(:total_retention_days) { plan_attrs.total_retention_days }
        ref.define_singleton_method(:uses_cold_storage?) { plan_attrs.uses_cold_storage? }
        ref.define_singleton_method(:backup_frequency) { plan_attrs.backup_frequency }
        ref.define_singleton_method(:estimated_monthly_cost) { plan_attrs.estimated_monthly_cost }
        
        ref
      end
    end
  end
end

# Auto-register this module when it's loaded
Pangea::ResourceRegistry.register(:aws, Pangea::Resources::AWS)