# frozen_string_literal: true

RSpec.describe 'portal/promo_card.json.jbuilder' do
  before do
    assign(:resource, resource)
  end

  context 'when resource is absent' do
    let(:resource) { nil }
    it 'is "null"' do
      render
      expect(rendered).to eq('null')
    end
  end

  context 'when resource is present' do
    let(:basic_resource) do
      {
        url: 'https://www.example.org/resource',
        title: 'Title',
        description: 'Description',
        images: %w(https://www.example.org/image.jpeg),
        logo: 'https://www.example.org/logo.jpeg',
        type: 'News',
        media_type: 'image',
        more_link_text: 'More news',
        count_label: '10 stories',
        date: '2018-11-20',
        attribution: 'Institiution'
      }
    end

    let(:resource) { basic_resource }
    let(:json) { JSON.parse(rendered).with_indifferent_access }

    %i(url title description images logo type media_type more_link_text count_label date attribution).each do |field|
      describe %(field "#{field}") do
        it 'is output' do
          render
          expect(json[field]).to eq(resource[field])
        end
      end
    end

    describe 'field "title"' do
      let(:resource) { basic_resource.merge(title: title) }

      context 'when text' do
        context 'with HTML' do
          let(:title) { '<h1>Title</h1>' }
          it 'has html stripped' do
            render
            expect(json[:title]).not_to start_with('<h1>')
          end
        end
      end

      context 'with nil value' do
        let(:title) { nil }
        it 'is output as nil' do
          render
          expect(json[:title]).to be_nil
        end
      end
    end

    describe 'field "description"' do
      let(:resource) { basic_resource.merge(description: description) }

      context 'when text' do
        context 'with HTML' do
          let(:description) { '<p>Description</p>' }
          it 'has it stripped' do
            render
            expect(json[:description]).not_to start_with('<p>')
          end
        end

        context 'when longer than 200 characters' do
          let(:description) { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec pulvinar dolor eu dolor cursus scelerisque. Nullam mollis neque in augue posuere, vitae pharetra elit scelerisque. Donec euismod orci eu cras amet.' }
          it 'is truncated' do
            render
            expect(json[:description].length).not_to be > 200
            expect(json[:description]).to end_with('...')
          end
        end
      end

      context 'with nil value' do
        let(:description) { nil }
        it 'is output as nil' do
          render
          expect(json[:description]).to be_nil
        end
      end
    end

    describe 'field "date"' do
      let(:resource) { basic_resource.merge(date: date_value) }
      dates = ['2018-11-20', '2018-11-20T16:52:52+01:00', Date.new(2018, 11, 20), DateTime.new(2018, 11, 20)]
      dates.each do |date|
        context "with value #{date.inspect}" do
          let(:date_value) { date }
          let(:resource) { basic_resource.merge(date: date) }
          it 'is output in Y-m-d format' do
            render
            expect(json[:date]).to eq('2018-11-20')
          end
        end
      end

      context 'with nil value' do
        let(:date_value) { nil }
        it 'is output as nil' do
          render
          expect(json[:date]).to be_nil
        end
      end
    end
  end
end
