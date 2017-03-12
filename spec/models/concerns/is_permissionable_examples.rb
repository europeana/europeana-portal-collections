shared_examples_for 'permissionable' do
  it { is_expected.to have_many(:permissions).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:permissions) }

  describe '#set_editor_permissions' do
    context 'when the uesr was an editor' do
      before do
        allow(::PaperTrail).to receive(:whodunnit) { users(:editor).id }
      end
      it 'should give the editor permissions on the object' do
        subject.set_editor_permissions
        expect(subject.permissions.first.user).to eq(users(:editor))
      end
    end
  end

end