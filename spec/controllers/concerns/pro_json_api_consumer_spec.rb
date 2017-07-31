# frozen_string_literal: true

RSpec.describe ProJsonApiConsumer do
  let(:controller_class) do
    Class.new(ApplicationController) do
      include ProJsonApiConsumer
    end
  end

  let(:controller_params) { {} }
  let(:controller_instance) { controller_class.new }

  subject { controller_instance }

  before do
    allow(controller_instance).to receive(:params) { controller_params }
  end

  describe '#pro_json_api_theme_filters_from_collections' do
    subject { controller_instance.send(:pro_json_api_theme_filters_from_collections) }

    it 'includes whitelisted collections' do
      controller_instance.send(:displayable_collections).each do |collection|
        key = collection.key.downcase
        expect(subject).to have_key(key.to_sym)
        expect(subject[key.to_sym]).to eq(filter: "culturelover-#{key}", label: collection.landing_page.title)
      end
    end
  end
end
