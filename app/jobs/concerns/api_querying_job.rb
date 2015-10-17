module ApiQueryingJob
  extend ActiveSupport::Concern

  include Blacklight::RequestBuilders

  included do
    self.search_params_logic = SearchBuilder.default_processor_chain
  end

  def blacklight_config
    @blacklight_config ||= PortalController.new.blacklight_config
  end

  def repository
    @repository ||= repository_class.new(blacklight_config)
  end

  def repository_class
    blacklight_config.repository_class
  end
end
