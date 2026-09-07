# frozen_string_literal: true

require_relative "pangea-discord/version"

Dir[File.join(__dir__, "pangea-discord", "resources", "*.rb")].each { |file| require file }

module PangeaDiscord
  class Error < StandardError; end
end
