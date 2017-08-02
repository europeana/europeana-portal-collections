# frozen_string_literal: true

RSpec.describe I18nHelper do
  describe '#date_eras_gregorian' do
    context 'before christ' do
      it 'converts gregorian before christ to correct format' do
        ['-1234', ' -1234', '-1234 ', ' -1234 ', '- 1234', ' - 1234', '- 1234 ', ' - 1234 '].each do |date|
          formatted_date = helper.date_eras_gregorian(date)
          expect(formatted_date).to eq('1234 BCE'), "date = '#{date}' has failed"
        end
      end

      it 'converts gregorian before christ yyyy-mm-dd to correct format' do
        expect(helper.date_eras_gregorian('-1033-02-15')).to eq('1033-02-15 BCE')
      end

      it 'strips off leading zeroes' do
        expect(helper.date_eras_gregorian('-0033')).to eq('33 BCE')
      end
    end

    context 'after christ' do
      it 'converts gregorian after christ to correct format' do
        ['+12', ' +12', '+12 ', ' +12 ', '+ 12', ' + 12', '+ 12 ', ' + 12 '].each do |date|
          formatted_date = helper.date_eras_gregorian(date)
          expect(formatted_date).to eq('12 CE'), "date = '#{date}' has failed"
        end
      end

      it 'converts gregorian after christ yyyy-mm-dd to correct format' do
        expect(helper.date_eras_gregorian('+56-01-01')).to eq('56-01-01 CE')
      end

      it 'strips off leading zeroes' do
        expect(helper.date_eras_gregorian('+066')).to eq('66 CE')
      end
    end

    context 'normal dates' do
      it 'leaves normal dates untouched' do
        ['1066', ' 1066', '1066 ', ' 1066 '].each do |date|
          formatted_date = helper.date_eras_gregorian(date)
          expect(formatted_date).to eq('1066'), "date = '#{date}' has failed"
        end
      end

      it 'leaves non-strings untouched' do
        [{}, [], nil, true].each do |date|
          formatted_date = helper.date_eras_gregorian(date)
          expect(formatted_date).to eq(date)
        end
      end
    end
  end
end
