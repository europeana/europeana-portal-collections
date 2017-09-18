# frozen_string_literal: true

RSpec.describe RepositoryHelper do
  let(:blacklight_config) { portal_controller.blacklight_config }

  describe '#blacklight_config' do
    it 'should return the blacklight_config from the portal controller' do
      expect(helper.blacklight_config).to be_a(Blacklight::Configuration)
    end
  end

  describe '#repository' do
    it 'should expose the "repository"' do
      expect(helper.repository).to be_a(blacklight_config.repository_class)
    end
  end

  describe '#repository_class' do
    it 'should get the repository class from the blacklight config' do
      expect(helper.repository_class).to eq(blacklight_config.repository_class)
    end
  end
end
