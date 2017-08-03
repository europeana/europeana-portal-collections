# frozen_string_literal: true

RSpec.describe I18nHelper do
  describe '#date_eras_gregorian' do
    context 'BCE' do
      it 'converts gregorian BCE to correct format' do
        ['-1234', ' -1234', '-1234 ', ' -1234 ', '- 1234', ' - 1234', '- 1234 ', ' - 1234 '].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq('1234 BCE')
        end
      end

      it 'converts gregorian BCE yyyy-mm-dd to correct format' do
        expect(helper.date_eras_gregorian('-1033-02-15')).to eq('1033-02-15 BCE')
      end

      it 'strips off leading zeroes' do
        expect(helper.date_eras_gregorian('-0033')).to eq('33 BCE')
      end
    end

    context 'CE' do
      it 'converts gregorian CE to correct format' do
        ['+12', ' +12', '+12 ', ' +12 ', '+ 12', ' + 12', '+ 12 ', ' + 12 '].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq('12 CE')
        end
      end

      it 'converts years < 1000 to correct gregorian CE format' do
        %w(6 66 666).each do |date|
          expect(helper.date_eras_gregorian(date)).to eq(date + ' CE')
        end
      end

      it 'converts gregorian CE yyyy-mm-dd to correct format' do
        expect(helper.date_eras_gregorian('+56-01-01')).to eq('56-01-01 CE')
      end

      it 'converts gregorian CE yyyy/mm/dd to correct format' do
        expect(helper.date_eras_gregorian('+56/01/01')).to eq('56/01/01 CE')
      end

      it 'strips off leading zero' do
        %w(+066 066).each do |date|
          expect(helper.date_eras_gregorian(date)).to eq('66 CE')
        end
      end

      it 'strips off leading zeroes' do
        %w(+006 006).each do |date|
          expect(helper.date_eras_gregorian(date)).to eq('6 CE')
        end
      end
    end

    context 'normal dates' do
      it 'leaves normal dates untouched' do
        ['1066', ' 1066', '1066 ', ' 1066 '].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq('1066')
        end
      end

      it 'leaves non-strings untouched' do
        [{}, [], nil, true].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq(date)
        end
      end
    end

    context 'malformed dates' do
      it 'leaves them untouched' do
        %w(--05-03 +0unknown).each do |date|
          expect(helper.date_eras_gregorian(date)).to eq(date)
        end
      end
    end
  end
end
