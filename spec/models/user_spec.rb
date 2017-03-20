# frozen_string_literal: true
RSpec.describe User do
  it { is_expected.to delegate_method(:role_enum).to(:class) }
  it { is_expected.to validate_inclusion_of(:role).in_array(%w(admin editor user)) }
  it { is_expected.to delegate_method(:can?).to(:ability) }
  it { is_expected.to delegate_method(:cannot?).to(:ability) }
  it { is_expected.to have_many(:permissions).inverse_of(:user).dependent(:destroy) }
  it { is_expected.to have_many(:permissionable_landing_pages).through(:permissions).class_name('Page') }
  it { is_expected.to have_many(:permissionable_galleries).through(:permissions).class_name('Gallery') }
  it { is_expected.to have_many(:permissionable_browse_entries).through(:permissions).class_name('BrowseEntry') }

  describe 'included modules' do
    subject { described_class }
    [
      PaperTrail::Model::InstanceMethods, Blacklight::User,
      Devise::Models::Trackable, Devise::Models::Validatable,
      Devise::Models::Recoverable, Devise::Models::Rememberable,
      Devise::Models::DatabaseAuthenticatable, Devise::Models::Authenticatable
    ].each do |mod|
      it { is_expected.to include(mod) }
    end
  end

  describe '.role_enum' do
    subject { described_class.role_enum }
    it { is_expected.to eq(%w(admin editor user)) }
  end

  describe '.permissionable_landing_page_ids_enum' do
    let(:permissionable_landing_pages) { Page.where(type: 'Page::Landing') }
    subject { described_class.permissionable_landing_page_ids_enum }
    it { is_expected.to eq(permissionable_landing_pages.map { |page| [page.title, page.id] }) }
  end

  describe '.permissionable_gallery_ids_enum' do
    let(:permissionable_galleries) { Gallery.all }
    subject { described_class.permissionable_gallery_ids_enum }
    it { is_expected.to eq(permissionable_galleries.map { |gallery| [gallery.title, gallery.id] }) }
  end

  describe '.permissionable_browse_entry_ids_enum' do
    let(:permissionable_browse_entries) { BrowseEntry.where(type: nil) }
    subject { described_class.permissionable_browse_entry_ids_enum }
    it { is_expected.to eq(permissionable_browse_entries.map { |entry| [entry.title, entry.id] }) }
  end

  describe '#ability' do
    subject { users(:user).ability }
    it { is_expected.to be_a(Ability) }
  end

  describe '#role' do
    context 'when blank' do
      let(:user) { users(:roleless) }
      it 'is set to "user"' do
        expect { user.save }.to change { user.role }.to('user')
      end
    end

    context 'when set' do
      let(:user) { users(:admin) }
      it 'is preserved' do
        expect { user.save }.not_to change { user.role }
      end
    end
  end
end
