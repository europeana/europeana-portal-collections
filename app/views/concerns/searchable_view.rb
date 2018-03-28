# frozen_string_literal: true

##
# View methods for searching
module SearchableView
  extend ActiveSupport::Concern

  def form_search
    {
      action: search_action_path(only_path: true)
    }.tap do |fs|

      # Auto-complete is not production ready. Only enable it on dev/test envs.
      if config.x.enable.search_form_autocomplete
        fs[:autocomplete] = {
          url: entities_suggest_url(format: 'json', text: ''),
          min_chars: 2,
          extended_info: config.x.enable.search_form_autocomplete_extended_info
        }
      end
    end
  end

  # model for the search form
  def input_search
    {
      title: t('global.search-area.search-button-image-alt'),
      input_name: params[:q].blank? ? 'q' : 'qf[]',
      has_original: !params[:q].blank?,
      input_original: {
        value:  params[:q].blank? ? nil : params[:q],
        remove: search_action_url(remove_q_param(params))
      },
      input_values: cacheable? ? nil : input_search_values(*search_param_keys),
      placeholder: t('site.search.placeholder.text')
    }
  end

  protected

  # @param keys [Symbol] keys of params to gather template input field data for
  # @return [Array<Hash>]
  def input_search_values(*keys)
    return [] if keys.blank?

    keys.map do |param_key|
      input_search_value_from_param(param_key)
    end.flatten.compact
  end

  def input_search_value_from_param(local_key, local_params = params, params_key = local_key)
    if local_params[local_key].is_a?(Hash)
      local_params[local_key].map do |param_sub_key, _param_sub_value|
        input_search_value_from_param(param_sub_key, local_params[local_key], params_key)
      end
    else
      [local_params[local_key]].flatten.compact.reject(&:blank?).map do |local_value|
        input_search_value_from_param_field(local_key, local_value, params_key)
      end
    end
  end

  def input_search_value_from_param_field(local_key, local_value, params_key = local_key)
    remove_params = remove_search_param(params_key, local_value, params)
    remove_params[:q] = '' if (params_key.to_s == 'mlt') && !remove_params.key?(:q)

    param_name = case params[params_key]
                 when Array
                   "#{params_key}[]"
                 when Hash
                   "#{params_key}[#{local_key}]"
                 else
                   params_key.to_s
                 end

    {
      name: param_name,
      is_mlt: local_key.to_s == 'mlt',
      value: local_value,
      text: input_search_value_from_param_field_text(local_key, local_value, params_key),
      remove: search_action_path(remove_params)
    }
  end

  def input_search_value_from_param_field_text(local_key, local_value, params_key = local_key)
    if params_key == :qe
      entity_type = local_key.split('/').first
      t('global.punctuation.term-list', term: t(entity_type, scope: 'site.entities.types'), items: local_value)
    else
      local_value
    end
  end

  ##
  # Keys of parameters to preserve across searches as hidden input fields
  #
  # @return [Array<Symbol>]
  def search_param_keys
    %i(qf mlt qe)
  end
end
