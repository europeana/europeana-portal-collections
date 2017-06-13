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

  describe '#pro_json_api_theme_filters_from_topics' do
    subject { controller_class.new.send(:pro_json_api_theme_filters_from_topics) }

    it 'includes all topics' do
      Topic.all.each do |topic|
        expect(subject).to have_key(topic.slug.to_sym)
        expect(subject[topic.slug.to_sym]).to eq( { filter: "culturelover-#{topic.slug}", label: topic.label } )
      end
    end
  end
end
