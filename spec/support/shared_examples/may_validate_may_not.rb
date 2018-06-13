# frozen_string_literal: true

shared_examples 'may validate may not' do |switch, method|
  context "when validating with #{switch}" do
    it 'is called' do
      expect(subject).to receive(method)
      subject.validating_with(switch) do
        subject.validate
      end
    end

    context "when validating without #{switch}" do
      it 'is not called' do
        expect(subject).not_to receive(method)
        subject.validate
      end
    end
  end
end
