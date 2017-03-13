# frozen_string_literal: true
shared_examples_for 'permissionable' do
  it { is_expected.to have_many(:permissions).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:permissions) }

  describe '#set_permissions' do
    context 'when the user was an editor' do
      before do
        allow(::PaperTrail).to receive(:whodunnit) { users(:editor).id }
      end
      it 'should give the editor permissions on the object' do
        subject.set_permissions
        expect(subject.permissions.first.user).to eq(users(:editor))
      end
    end

    context 'when the user was an admin' do
      before do
        allow(::PaperTrail).to receive(:whodunnit) { users(:admin).id }
      end
      it 'should not try to set permissions on the object' do
        subject.set_permissions
        expect(subject.permissions.count).to eq(0)
      end
    end
  end
end
