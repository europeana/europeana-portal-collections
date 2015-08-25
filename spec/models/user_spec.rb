RSpec.describe User do
  it 'includes Blacklight::User' do
    expect(described_class).to include(Blacklight::User)
  end

  [Devise::Models::Trackable, Devise::Models::Validatable,
   Devise::Models::Recoverable, Devise::Models::Rememberable,
   Devise::Models::DatabaseAuthenticatable, Devise::Models::Authenticatable
  ].each do |mod|
    it "is #{mod.to_s.demodulize.titleize} with Devise" do
      expect(described_class).to include(mod)
    end
  end

  it 'has paper trail' do
    expect(described_class).to include(PaperTrail::Model::InstanceMethods)
  end

  describe '::ROLES' do
    it 'contains required user roles for the app' do
      expect(described_class::ROLES).to eq(%w(user admin))
    end
  end

  it { is_expected.to validate_inclusion_of(:role).in_array(%w(user admin)) }

  describe '#ability' do
    it 'returns instance of Ability for the user' do
      expect(described_class.new.ability).to be_a(Ability)
    end
  end

  it { is_expected.to delegate_method(:can?).to(:ability) }
  it { is_expected.to delegate_method(:cannot?).to(:ability) }

  describe '#role' do
    context 'when blank' do
      it 'is set to "user"' do
        user = described_class.new(email: 'test@example.com', password: 'secret!!')
        expect { user.save }.to change{ user.role }.to('user')
      end
    end

    context 'when set' do
      let(:user) { described_class.new(email: 'test@example.com', password: 'secret!!', role: 'admin') }
      it 'is preserved' do
        expect { user.save }.not_to change{ user.role }
      end
    end
  end

  describe '#role_enum' do
    it 'returns valid roles' do
      expect(described_class.new.role_enum).to eq(described_class::ROLES)
    end
  end
end
