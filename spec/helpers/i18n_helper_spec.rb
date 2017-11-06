# frozen_string_literal: true

require 'helpers/i18n_helper_examples'

RSpec.describe I18nHelper do
  subject { helper }
  it_behaves_like 'i18n_helper'
end
