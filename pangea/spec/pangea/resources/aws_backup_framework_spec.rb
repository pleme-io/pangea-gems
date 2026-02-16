# frozen_string_literal: true

require 'spec_helper'
require 'pangea/resources/aws_backup_framework/resource'
require 'pangea/resources/aws_backup_framework/types'

RSpec.describe 'Pangea::Resources::AWS#aws_backup_framework' do
  include Pangea::Resources::AWS
  
  let(:mock_terraform_synthesizer) { instance_double(TerraformSynthesizer) }
  let(:mock_synthesis_context) { double('SynthesisContext') }
  
  before do
    allow(TerraformSynthesizer).to receive(:new).and_return(mock_terraform_synthesizer)
    allow(mock_terraform_synthesizer).to receive(:instance_eval)
    allow(mock_terraform_synthesizer).to receive(:synthesis).and_return(mock_synthesis_context)
    
    # Mock the resource method with all necessary methods
    allow(self).to receive(:resource) do |resource_type, name, &block|
      if block_given?
        mock_resource_context = Object.new
        
        # Define all expected methods
        %w[name description control input_parameter parameter_name parameter_value
           scope compliance_resource_types tags].each do |method_name|
          mock_resource_context.define_singleton_method(method_name) { |value = nil, &inner_block| }
        end
        
        mock_resource_context.instance_eval(&block)
      end
    end
  end

  describe '#aws_backup_framework' do
    context 'with valid attributes' do
      it 'creates a basic backup framework' do
        result = aws_backup_framework(:basic_framework, {
          name: "BasicComplianceFramework",
          description: "Basic compliance framework",
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
            }
          ]
        })
        
        expect(result).to be_a(Pangea::Resources::ResourceReference)
        expect(result.type).to eq('aws_backup_framework')
        expect(result.name).to eq(:basic_framework)
        expect(result.resource_attributes[:name]).to eq("BasicComplianceFramework")
      end
      
      it 'creates a framework with frequency controls' do
        result = aws_backup_framework(:frequency_framework, {
          name: "FrequencyFramework",
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
              ]
            }
          ]
        })
        
        expect(result.has_frequency_controls).to be true
        expect(result.has_encryption_controls).to be false
        expect(result.complexity_score).to be > 20
      end
      
      it 'creates a framework with encryption controls' do
        result = aws_backup_framework(:encryption_framework, {
          name: "EncryptionFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        expect(result.has_encryption_controls).to be true
        expect(result.has_frequency_controls).to be false
      end
      
      it 'creates a framework with deletion protection' do
        result = aws_backup_framework(:protection_framework, {
          name: "ProtectionFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
            }
          ]
        })
        
        expect(result.has_deletion_protection_controls).to be true
      end
      
      it 'creates a framework with resource scope filtering' do
        result = aws_backup_framework(:scoped_framework, {
          name: "ScopedFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
              scope: {
                compliance_resource_types: ["EBS", "RDS"],
                tags: {
                  "Environment" => "production"
                }
              }
            }
          ]
        })
        
        expect(result.covered_resource_types).to include("EBS", "RDS")
      end
      
      it 'creates a comprehensive compliance framework' do
        result = aws_backup_framework(:compliance_framework, {
          name: "ComplianceFramework",
          description: "Comprehensive compliance framework",
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
                compliance_resource_types: ["EBS", "RDS"],
                tags: {
                  "Environment" => "production"
                }
              }
            },
            {
              name: "BACKUP_PLAN_MIN_FREQUENCY_AND_MIN_RETENTION_CHECK",
              input_parameter: [
                {
                  parameter_name: "requiredRetentionDays",
                  parameter_value: "30"
                }
              ]
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ],
          tags: {
            Environment: "production",
            ComplianceRequired: "true"
          }
        })
        
        expect(result.has_frequency_controls).to be true
        expect(result.has_encryption_controls).to be true
        expect(result.is_compliance_framework).to be true
        expect(result.complexity_score).to be > 50
      end
      
      it 'returns reference with all terraform outputs' do
        result = aws_backup_framework(:full_output, {
          name: "FullOutputFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        expect(result.id).to eq("${aws_backup_framework.full_output.id}")
        expect(result.arn).to eq("${aws_backup_framework.full_output.arn}")
        expect(result.name).to eq("${aws_backup_framework.full_output.name}")
        expect(result.status).to eq("${aws_backup_framework.full_output.status}")
        expect(result.creation_time).to eq("${aws_backup_framework.full_output.creation_time}")
      end
      
      it 'provides computed properties' do
        result = aws_backup_framework(:computed_props, {
          name: "ComputedPropsFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "days"
                }
              ]
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        expect(result.has_frequency_controls).to be true
        expect(result.has_encryption_controls).to be true
        expect(result.estimated_monthly_cost_usd).to be_a(Float)
        expect(result.recommended_evaluation_frequency).to be_a(String)
        expect(result.framework_summary).to include("ComputedPropsFramework")
      end
    end
    
    context 'with invalid attributes' do
      it 'raises error for missing name' do
        expect {
          aws_backup_framework(:invalid, {
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
              }
            ]
          })
        }.to raise_error(Dry::Struct::Error, /name is missing/)
      end
      
      it 'raises error for empty framework name' do
        expect {
          aws_backup_framework(:invalid, {
            name: "",
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
              }
            ]
          })
        }.to raise_error(Dry::Struct::Error, /Framework name must be 1-256 characters/)
      end
      
      it 'raises error for framework name too long' do
        expect {
          aws_backup_framework(:invalid, {
            name: "a" * 257,
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
              }
            ]
          })
        }.to raise_error(Dry::Struct::Error, /Framework name must be 1-256 characters/)
      end
      
      it 'raises error for invalid framework name characters' do
        expect {
          aws_backup_framework(:invalid, {
            name: "invalid@name",
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
              }
            ]
          })
        }.to raise_error(Dry::Struct::Error, /Framework name contains invalid characters/)
      end
      
      it 'raises error for description too long' do
        expect {
          aws_backup_framework(:invalid, {
            name: "test-framework",
            description: "a" * 1025,
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
              }
            ]
          })
        }.to raise_error(Dry::Struct::Error, /Framework description cannot exceed 1024 characters/)
      end
      
      it 'raises error for no controls' do
        expect {
          aws_backup_framework(:invalid, {
            name: "test-framework",
            control: []
          })
        }.to raise_error(Dry::Struct::Error, /Framework must have at least one control/)
      end
      
      it 'raises error for invalid control name' do
        expect {
          aws_backup_framework(:invalid, {
            name: "test-framework",
            control: [
              {
                name: "INVALID_CONTROL_NAME"
              }
            ]
          })
        }.to raise_error(Dry::Struct::Error, /Invalid control name/)
      end
      
      it 'raises error for duplicate control names' do
        expect {
          aws_backup_framework(:invalid, {
            name: "test-framework",
            control: [
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
              },
              {
                name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
              }
            ]
          })
        }.to raise_error(Dry::Struct::Error, /Duplicate control names found/)
      end
    end
  end
  
  describe Pangea::Resources::AWS::InputParameter do
    it 'identifies frequency unit parameters' do
      param = described_class.new({
        parameter_name: "requiredFrequencyUnit",
        parameter_value: "days"
      })
      
      expect(param.is_frequency_unit?).to be true
      expect(param.is_frequency_value?).to be false
    end
    
    it 'identifies frequency value parameters' do
      param = described_class.new({
        parameter_name: "requiredFrequencyValue",
        parameter_value: "24"
      })
      
      expect(param.is_frequency_value?).to be true
      expect(param.parameter_value_as_int).to eq(24)
    end
    
    it 'identifies retention parameters' do
      param = described_class.new({
        parameter_name: "requiredRetentionDays",
        parameter_value: "30"
      })
      
      expect(param.is_retention_parameter?).to be true
      expect(param.parameter_value_as_int).to eq(30)
    end
    
    it 'handles non-numeric parameter values' do
      param = described_class.new({
        parameter_name: "requiredFrequencyUnit",
        parameter_value: "hours"
      })
      
      expect(param.parameter_value_as_int).to be_nil
    end
  end
  
  describe Pangea::Resources::AWS::ControlScope do
    it 'applies to specific resource types' do
      scope = described_class.new({
        compliance_resource_types: ["EBS", "RDS"]
      })
      
      expect(scope.applies_to_resource_type?("EBS")).to be true
      expect(scope.applies_to_resource_type?("S3")).to be false
    end
    
    it 'applies to all resource types when none specified' do
      scope = described_class.new({})
      
      expect(scope.applies_to_resource_type?("EBS")).to be true
      expect(scope.applies_to_resource_type?("S3")).to be true
    end
    
    it 'detects tag filtering' do
      scope = described_class.new({
        tags: { "Environment" => "production" }
      })
      
      expect(scope.has_tag_filtering?).to be true
    end
    
    it 'generates resource types summary' do
      scope = described_class.new({
        compliance_resource_types: ["EBS", "RDS"]
      })
      
      expect(scope.resource_types_summary).to eq("EBS, RDS")
    end
    
    it 'handles empty resource types' do
      scope = described_class.new({})
      
      expect(scope.resource_types_summary).to eq("All resource types")
    end
  end
  
  describe Pangea::Resources::AWS::FrameworkControl do
    it 'validates control names' do
      expect {
        described_class.new({
          name: "INVALID_CONTROL",
          input_parameter: []
        })
      }.to raise_error(Dry::Struct::Error, /Invalid control name/)
    end
    
    it 'identifies frequency controls' do
      control = described_class.new({
        name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
        input_parameter: []
      })
      
      expect(control.is_frequency_control?).to be true
      expect(control.is_encryption_control?).to be false
    end
    
    it 'identifies encryption controls' do
      control = described_class.new({
        name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
        input_parameter: []
      })
      
      expect(control.is_encryption_control?).to be true
      expect(control.is_frequency_control?).to be false
    end
    
    it 'identifies deletion protection controls' do
      control = described_class.new({
        name: "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED",
        input_parameter: []
      })
      
      expect(control.is_deletion_protection_control?).to be true
    end
    
    it 'extracts frequency parameters' do
      control = described_class.new({
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
        ]
      })
      
      freq_params = control.frequency_parameters
      expect(freq_params[:unit]).to eq("hours")
      expect(freq_params[:value]).to eq(24)
    end
    
    it 'detects resource filtering' do
      control = described_class.new({
        name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
        scope: {
          compliance_resource_types: ["EBS", "RDS"]
        }
      })
      
      expect(control.has_resource_filtering?).to be true
    end
    
    it 'generates control summary' do
      control = described_class.new({
        name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
        scope: {
          compliance_resource_types: ["EBS", "RDS"]
        }
      })
      
      summary = control.control_summary
      expect(summary).to include("Backup Recovery Point Encrypted")
      expect(summary).to include("EBS, RDS")
    end
  end
  
  describe Pangea::Resources::AWS::BackupFrameworkAttributes do
    describe 'framework analysis' do
      it 'identifies compliance frameworks' do
        framework = described_class.new({
          name: "compliance-framework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: []
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
              input_parameter: []
            }
          ]
        })
        
        expect(framework.is_compliance_framework?).to be true
        expect(framework.is_basic_framework?).to be false
      end
      
      it 'identifies basic frameworks' do
        framework = described_class.new({
          name: "basic-framework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: []
            }
          ]
        })
        
        expect(framework.is_basic_framework?).to be false  # Has frequency control
        expect(framework.is_compliance_framework?).to be false  # No encryption
      end
      
      it 'calculates complexity score' do
        simple_framework = described_class.new({
          name: "simple",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        complex_framework = described_class.new({
          name: "complex",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              scope: {
                compliance_resource_types: ["EBS"]
              }
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            },
            {
              name: "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
            }
          ]
        })
        
        expect(complex_framework.complexity_score).to be > simple_framework.complexity_score
      end
    end
    
    describe 'cost estimation' do
      it 'estimates monthly cost' do
        framework = described_class.new({
          name: "test-framework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        cost = framework.estimated_monthly_cost_usd
        expect(cost).to be_a(Float)
        expect(cost).to be > 0
      end
      
      it 'includes control complexity in cost' do
        simple_framework = described_class.new({
          name: "simple",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        complex_framework = described_class.new({
          name: "complex",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY"
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        expect(complex_framework.estimated_monthly_cost_usd).to be > simple_framework.estimated_monthly_cost_usd
      end
    end
    
    describe 'evaluation recommendations' do
      it 'recommends evaluation frequency based on controls' do
        daily_framework = described_class.new({
          name: "daily",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY"
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        weekly_framework = described_class.new({
          name: "weekly",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
            }
          ]
        })
        
        expect(daily_framework.recommended_evaluation_frequency).to eq("daily")
        expect(weekly_framework.recommended_evaluation_frequency).to eq("weekly")
      end
    end
    
    describe 'resource type coverage' do
      it 'identifies covered resource types' do
        framework = described_class.new({
          name: "scoped-framework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
              scope: {
                compliance_resource_types: ["EBS", "RDS"]
              }
            }
          ]
        })
        
        expect(framework.covered_resource_types).to include("EBS", "RDS")
        expect(framework.applies_to_resource_type?("EBS")).to be true
        expect(framework.applies_to_resource_type?("S3")).to be false
      end
      
      it 'handles frameworks without resource filtering' do
        framework = described_class.new({
          name: "unscoped-framework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
        
        expect(framework.covered_resource_types).to include("All resource types")
      end
    end
  end
  
  describe Pangea::Resources::AWS::BackupFrameworkConfigs do
    describe '.basic_compliance' do
      it 'provides basic compliance configuration' do
        config = described_class.basic_compliance(framework_name: "test-basic")
        
        expect(config[:name]).to eq("test-basic")
        expect(config[:control]).to have(2).items
        expect(config[:control].first[:name]).to include("FREQUENCY")
        expect(config[:tags][:Purpose]).to eq("compliance")
      end
    end
    
    describe '.production_compliance' do
      it 'provides production compliance configuration' do
        config = described_class.production_compliance(
          framework_name: "test-production",
          resource_types: ["EBS", "RDS", "DynamoDB"]
        )
        
        expect(config[:name]).to eq("test-production")
        expect(config[:control]).to have(4).items
        expect(config[:tags][:Environment]).to eq("production")
        
        # Check resource filtering
        scoped_control = config[:control].find { |c| c[:scope] }
        expect(scoped_control[:scope][:compliance_resource_types]).to include("EBS", "RDS", "DynamoDB")
      end
    end
    
    describe '.database_protection' do
      it 'provides database-focused configuration' do
        config = described_class.database_protection(framework_name: "test-database")
        
        expect(config[:name]).to eq("test-database")
        expect(config[:tags][:Purpose]).to eq("database-protection")
        
        # All controls should be database-focused
        config[:control].each do |control|
          if control[:scope]
            expect(control[:scope][:compliance_resource_types]).to include("RDS").or include("DynamoDB")
          end
        end
      end
    end
    
    describe '.development_basic' do
      it 'provides development configuration' do
        config = described_class.development_basic(framework_name: "test-dev")
        
        expect(config[:name]).to eq("test-dev")
        expect(config[:control]).to have(1).item
        expect(config[:tags][:Environment]).to eq("development")
        expect(config[:tags][:CostOptimized]).to eq("true")
      end
    end
  end
end