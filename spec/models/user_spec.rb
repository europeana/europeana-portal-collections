RSpec.describe User do
  [Devise::Models::Trackable, Devise::Models::Validatable, Devise::Models::Recoverable, Devise::Models::Rememberable, Devise::Models::DatabaseAuthenticatable, Devise::Models::Authenticatable].each do |mod|
    it "is #{mod.to_s.demodulize.titleize} with Devise" do
      expect(described_class).to include(mod)
    end
  end

  describe '#ability' do
    it 'returns instance of Ability for the user' do
      expect(User.new.ability).to be_a(Ability)
    end
  end

  describe '#can?' do
    it 'is delegated to #ability'
  end
end
