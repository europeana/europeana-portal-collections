# frozen_string_literal: true
Foederati.configure do
  api_keys.dpla = ENV['FEDERATED_SEARCH_API_KEYS_DPLA']
  api_keys.digitalnz = ENV['FEDERATED_SEARCH_API_KEYS_DIGITALNZ']
  api_keys.trove = ENV['FEDERATED_SEARCH_API_KEYS_TROVE']

  defaults.limit = 4
end
