RSpec.describe User do
  it 'includes Blacklight::User' do
    expect(described_class).to include(Blacklight::User)
  end

  describe 'Devise modules' do
    subject { described_class }
    [Devise::Models::Trackable, Devise::Models::Validatable,
     Devise::Models::Recoverable, Devise::Models::Rememberable,
     Devise::Models::DatabaseAuthenticatable, Devise::Models::Authenticatable
    ].each do |mod|      
      it { is_expected.to include(mod) }
    end
  end

  it 'has paper trail' do
    expect(described_class).to include(PaperTrail::Model::InstanceMethods)
  end

  describe '::ROLES' do
    subject { described_class::ROLES }
    it { is_expected.to eq(%w(user admin)) }
  end

  it { is_expected.to validate_inclusion_of(:role).in_array(%w(user admin)) }

  describe '#ability' do
    subject { FactoryGirl.create(:user).ability }
    it { is_expected.to be_a(Ability) }
  end

  it { is_expected.to delegate_method(:can?).to(:ability) }
  it { is_expected.to delegate_method(:cannot?).to(:ability) }

  describe '#role' do
    context 'when blank' do
      let(:user) { FactoryGirl.build(:user, :guest) }
      it 'is set to "user"' do
        expect { user.save }.to change { user.role }.to('user')
      end
    end

    context 'when set' do
      let(:user) { FactoryGirl.create(:user, :admin) }
      it 'is preserved' do
        expect { user.save }.not_to change { user.role }
      end
    end
  end

  describe '#role_enum' do
    subject { FactoryGirl.create(:user).role_enum }
    it { is_expected.to eq(described_class::ROLES) }
  end
end
