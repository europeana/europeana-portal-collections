# frozen_string_literal: true

RSpec::Matchers.define :enforce_default_format do |format|
  match do |actual|
    subject.call
    @redirect_url = request.params.merge(format: format)
    expect(response).to redirect_to(@redirect_url)
  end

  failure_message do |actual|
    %(expected response to enforce format "#{format}" by redirecting to URL for params: #{@redirect_url})
  end
end

