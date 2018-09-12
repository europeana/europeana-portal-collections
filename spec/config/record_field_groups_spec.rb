# frozen_string_literal: true

RSpec.describe 'config/record_field_groups.yml' do
  FIELD_GROUPS = %w(concepts copyright creators time description location people provenance properties refs_rels).freeze
  FIELD_GROUP_KEYS = %w(title sections).freeze
  SECTION_KEYS = %w(title geo entity fields search_field quoted ga_data exclude_vals map_values capitalised format_date max html_line_breaks).freeze
  ENTITY_KEYS = %w(name fallback extra).freeze

  let(:file_path) { File.join(Rails.root, 'config', 'record_field_groups.yml') }
  let(:config) { YAML.load_file(file_path).with_indifferent_access.freeze }

  subject { config }

  it 'has required field groups' do
    expect(subject.keys).to eq(FIELD_GROUPS)
  end

  FIELD_GROUPS.each do |group|
    describe %(field group "#{group}") do
      subject { config[group] }

      it 'has valid keys' do
        subject.each_key do |key|
          expect(FIELD_GROUP_KEYS).to include(key)
        end
      end

      describe 'sections' do
        subject { config[group][:sections] }

        it 'have valid keys' do
          subject.each do |section|
            section.each_key do |key|
              expect(SECTION_KEYS).to include(key)
            end
          end
        end

        it 'must have fields' do
          subject.each do |section|
            expect(section).to have_key(:fields)
          end
        end

        describe 'entities' do
          it 'must have valid keys' do
            subject.each do |section|
              next unless section.key?(:entity)
              section[:entity].each_key do |key|
                expect(ENTITY_KEYS).to include(key)
              end
            end
          end
        end
      end
    end
  end
end
