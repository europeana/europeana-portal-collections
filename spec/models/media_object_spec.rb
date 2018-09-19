# frozen_string_literal: true

RSpec.describe MediaObject do
  it 'has Paperclip attachment' do
    expect(Paperclip::AttachmentRegistry.instance.names_for(described_class)).
      to include(:file)
  end

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

  it 'optimizes images' do
    image_path = File.expand_path('../support/media/image.jpg', __dir__)
    file = File.open(image_path)
    mo = MediaObject.new
    mo.file = file
    mo.save!
    expect(mo).to be_persisted
    full_url = mo.file.url(:full)
    full_image = Faraday.get(full_url)
    full_image_size = full_image.headers['content-length'].to_i
    expect(full_image_size).to be_positive
    expect(full_image_size).to be < mo.file.size
  end
end
