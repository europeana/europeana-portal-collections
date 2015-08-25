RSpec.describe Ability do
  it 'uses CanCan' do
    expect(described_class).to include(CanCan::Ability)
  end

  let(:user) { User.new(role: role) }

  context 'without user role (guest)' do
    let(:role) { nil }
    it 'permits access to RailsAdmin' do
      expect(user.can?(:access, :rails_admin)).to be false
    end
    it 'permits access to admin dashboard' do
      expect(user.can?(:access, :dashboard)).to be false
    end
    it 'permits access to manage users' do
      expect(user.can?(:manage, User.new)).to be false
    end
    it 'denies access to manage media objects' do
      expect(user.can?(:manage, MediaObject.new)).to be false
    end
  end

  context 'when user role is "user"' do
    let(:role) { 'user' }
    it 'permits access to RailsAdmin' do
      expect(user.can?(:access, :rails_admin)).to be false
    end
    it 'permits access to admin dashboard' do
      expect(user.can?(:access, :dashboard)).to be false
    end
    it 'permits access to manage users' do
      expect(user.can?(:manage, User.new)).to be false
    end
    it 'denies access to manage media objects' do
      expect(user.can?(:manage, MediaObject.new)).to be false
    end
  end

  context 'when user role is "admin"' do
    let(:role) { 'admin' }
    it 'permits access to RailsAdmin' do
      expect(user.can?(:access, :rails_admin)).to be true
    end
    it 'permits access to admin dashboard' do
      expect(user.can?(:access, :dashboard)).to be true
    end
    it 'permits access to manage users' do
      expect(user.can?(:manage, User.new)).to be true
    end
    it 'denies access to manage media objects' do
      expect(user.can?(:manage, MediaObject.new)).to be false
    end
  end
end
