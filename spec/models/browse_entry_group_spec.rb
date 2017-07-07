# frozen_string_literal: true

RSpec.describe BrowseEntryGroup do
  subject do
    described_class.new(page: pages(:music_collection)).tap do |group|
      group.title = 'topic'
    end
  end

  it { is_expected.to have_many(:browse_entries).through(:elements) }
  it { is_expected.to delegate_method(:title_enum).to(:class) }
  it { is_expected.to validate_presence_of(:browse_entries) }
  it { is_expected.to validate_inclusion_of(:title).in_array(%w(topic person period)) }

  it 'may contain browse entries of one subject type' do
    subject.browse_entries << browse_entries(:opera_topic)
    subject.browse_entries << browse_entries(:cinema_topic)
    subject.browse_entries << browse_entries(:harp_topic)
    expect(subject).to be_valid
  end

  it 'may not contain browse entries of more than one subject type' do
    subject.browse_entries << browse_entries(:opera_topic)
    subject.browse_entries << browse_entries(:cinema_topic)
    subject.browse_entries << browse_entries(:hokusai_person)
    expect(subject).not_to be_valid
    expect(subject.errors[:browse_entries]).to include('must all be of the same subject type, "topic"')
  end

  it 'may only contain browse entries in multiples of 3' do
    subject.browse_entries << browse_entries(:opera_topic)
    expect(subject).not_to be_valid
    subject.browse_entries << browse_entries(:cinema_topic)
    expect(subject).not_to be_valid
    subject.browse_entries << browse_entries(:music_topic)
    expect(subject).to be_valid
    subject.browse_entries << browse_entries(:harp_topic)
    expect(subject).not_to be_valid
    subject.browse_entries << browse_entries(:manuscripts_topic)
    expect(subject).not_to be_valid
    subject.browse_entries << browse_entries(:books_topic)
    expect(subject).to be_valid
    subject.browse_entries << browse_entries(:paintings_topic)
    expect(subject).not_to be_valid
  end
end
