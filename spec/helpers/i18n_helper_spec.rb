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

      it 'omits CE from years > 1000' do
        ['1066', ' 1066', '1066 ', ' 1066 ', '1066 AD', 'c. 1066', 'c.1066', 'c. 1066 AD'].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq('1066')
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
      it 'leaves non-strings untouched' do
        [{}, [], nil, true].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq(date)
        end
      end
    end

    context 'dates in other eras' do
      it 'leaves them untouched' do
        ['AH 1014'].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq(date)
        end
      end
    end

    context 'abnormal dates' do
      it 'handles abnormal formats correctly' do
        ['c. AD 46', 'a. de C. 46', 'c. 46', 'c.46', 'c.46 AD', 'circa 46'].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq('46 CE')
        end
        ['About 470 BC', 'About 470 BCE', 'c.470 BCE', 'circa 470 BCE'].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq('470 BCE')
        end
      end
    end

    context 'malformed dates' do
      it 'leaves them untouched' do
        ['--05-03', '+0unknown', 'Amsterdam, Netherlands', '-10-1500-04'].each do |date|
          expect(helper.date_eras_gregorian(date)).to eq(date)
        end
      end
    end
  end
end
