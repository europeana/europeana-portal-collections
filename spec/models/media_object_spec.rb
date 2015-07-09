require 'rails_helper'

RSpec.describe MediaObject, type: :model do
  subject { described_class.new }

  it 'has Paperclip attachment' do
    expect(Paperclip::AttachmentRegistry.instance.names_for(described_class)).
      to include(:file)
  end

  it 'resizes images to three max-width sizes'

  context 'with source URL' do
    before do
      subject.source_url = 'http://www.example.com/'
    end
    it 'generates an MD5 hash of the source URL' do
      expect { subject.save }.to change { subject.source_url_hash }.from(nil).
        to('f1777111f5d0f1c81ffa04de751128fa')
    end
  end

  context 'without source URL' do
    it 'leaves hash field blank' do
      expect { subject.save }.not_to change { subject.source_url_hash }
      expect(subject.source_url_hash).to be_nil
    end
  end
end
