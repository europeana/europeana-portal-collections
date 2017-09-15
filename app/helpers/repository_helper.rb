# frozen_string_literal: true

module RepositoryHelper
  def blacklight_config
    @blacklight_config ||= begin
      PortalController.new.blacklight_config
    end
  end

  def repository
    @repository ||= repository_class.new(blacklight_config)
  end

  def repository_class
    blacklight_config.repository_class
  end
end
