# frozen_string_literal: true
class Collection < ActiveRecord::Base
  include HasPublicationStates
  include HasSettingsAttribute

  has_and_belongs_to_many :browse_entries
  has_one :landing_page, class_name: 'Page::Landing', dependent: :destroy
  has_many :federation_configs, dependent: :destroy

  accepts_nested_attributes_for :federation_configs

  has_paper_trail

  validates :key, presence: true, uniqueness: true
  validates :api_params, presence: true

  after_save :touch_landing_page

  translates :title, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  has_settings :default_search_layout
  has_settings :federated_providers

  delegate :settings_default_search_layout_enum, to: :class
  class << self
    def settings_default_search_layout_enum
      %w(list grid)
    end
  end

  def to_param
    key
  end

  def api_params_hash
    {}.tap do |hash|
      api_params.split('&').map do |param|
        key, val = param.split('=')
        hash[key] ||= []
        hash[key] << val
      end
    end
  end

  def has_landing_page?
    landing_page.present?
  end

  def landing_page_title
    landing_page.present? ? landing_page.title : nil
  end

  def touch_landing_page
    landing_page.touch if landing_page.present?
  end

  def after_publish
    trigger_record_counts_job
  end

  def trigger_record_counts_job
    Cache::RecordCountsJob.perform_later(id, types: true)
  end

  def accepts_ugc?
    self.class.ugc_acceptor_keys.include?(key)
  end

  # TODO: do not hardcode this; make a db-stored attribute of the model?
  def self.ugc_acceptor_keys
    %w(world-war-I)
  end
end
