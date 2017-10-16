# frozen_string_literal: true

RSpec.describe NamedEntityDisplayingView do
  let(:view_class) do
    Class.new do
      include NamedEntityDisplayingView
    end
  end

  let(:view_instance) { view_class.new }

  describe '#linkable_named_entity_value?' do
    subject { view_instance.linkable_named_entity_value?(field, value) }

    %i(begin end latitude longitude prefLabel).each do |unlinkable_field|
      context %(when field is "#{unlinkable_field}") do
        let(:field) { unlinkable_field }
        let(:value) { 'http://www.example.com/' }

        it { is_expected.to be false }
      end
    end

    %i(about broader).each do |linkable_field|
      context %(when field is "#{linkable_field}") do
        let(:field) { linkable_field }

        context 'when value is http URL' do
          let(:value) { 'http://www.example.com/' }
          it { is_expected.to be true }
        end

        context 'when value is https URL' do
          let(:value) { 'https://www.example.com/' }
          it { is_expected.to be true }
        end

        context 'when value is non-URL String' do
          let(:value) { 'www.example.com' }
          it { is_expected.to be false }
        end

        context 'when value is non-String' do
          let(:value) { %w(http://www.example.com/) }
          it { is_expected.to be false }
        end
      end
    end
  end

  describe '#normalise_named_entity' do
    subject { view_instance.normalise_named_entity(value) }

    context 'when value is Hash' do
      context 'with multiple language keys' do
        let(:value) { { en: 'Yes', fr: 'Oui' } }

        it 'should normalise all' do
          expect(subject).to be_a(Array)
          expect(subject.size).to eq(2)
          expect(subject.all? { |element| element.is_a?(Hash) }).to be true

          english = subject.detect { |element| element[:key] == :en }
          expect(english).not_to be_nil
          expect(english[:val]).to eq(value[:en])

          french = subject.detect { |element| element[:key] == :fr }
          expect(french).not_to be_nil
          expect(french[:val]).to eq(value[:fr])
        end
      end

      context 'with only "def" key' do
        context 'with one value' do
          let(:value) { { def: ['Single value'] } }

          it 'should not normalise' do
            expect(subject).to eq(value[:def])
          end
        end

        context 'with multiple values' do
          let(:value) { { def: ['Value 1', 'Value 2'] } }

          it 'should be normalised' do
            expect(subject).to be_a(Array)
            expect(subject.size).to eq(1)
            expect(subject.first).to be_a(Hash)
            expect(subject.first[:key]).to eq(:def)
            expect(subject.first[:val]).to eq(value[:def])
          end
        end
      end
    end
  end
end
