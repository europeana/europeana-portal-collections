# frozen_string_literal: true

RSpec.describe 'HTTP OPTIONS requests' do
  %w(/en /de/collections/music /fr/search /nl/record/123/abc.html).each do |path|
    context "when path is #{path}" do
      it 'responds with 204 No Content' do
        options(path)
        expect(response.body).to eq('')
        expect(response.status).to eq(204)
      end
    end
  end
end
