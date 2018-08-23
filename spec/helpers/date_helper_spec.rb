# frozen_string_literal: true

RSpec.describe DateHelper do
  describe '#format_date' do
    subject { helper.format_date(text, format) }

    let(:unformatted_date) { '2018-08-13T16:24:46.952+02:00' }
    let(:date_format_year_month_day) { '%Y-%m-%d' }
    let(:formatted_date) { '2018-08-13' }

    context 'when format is nil' do
      let(:format) { nil }
      let(:text) { unformatted_date }

      it 'should equal text' do
        expect(subject).to eq(text)
      end
    end

    context 'when format is valid' do
      context 'when text does not contain "-"' do
        let(:text) { '01/02/1970' }
        let(:format) { date_format_year_month_day }

        it 'should equal text' do
          expect(subject).to eq(text)
        end
      end

      context 'when text starts with "-"' do
        let(:text) { '-1200' }
        let(:format) { date_format_year_month_day }

        it 'should equal text' do
          expect(subject).to eq(text)
        end
      end

      context 'when text contains "-" after first char' do
        context 'and is parsable' do
          let(:text) { unformatted_date }
          let(:format) { date_format_year_month_day }

          it 'should equal formatted date' do
            expect(subject).to eq(formatted_date)
          end
        end

        context 'but is not parsable' do
          let(:text) { '1200-1300' }
          let(:format) { date_format_year_month_day }

          it 'should equal text' do
            expect(subject).to eq(text)
          end
        end
      end
    end
  end
end
