RSpec.describe FeedbackController do
  describe 'POST create' do
    let(:params) { { locale: 'en', type: 'comment', text: 'This is good!', url: home_url(locale: 'en') } }
    subject { post :create, params }

    it 'should queue an email job' do
      expect { subject }.to change { Delayed::Job.where("handler LIKE '%FeedbackMailer%'").count }.by(1)
    end

    it 'should return a nice message'

    it 'should fail if recipient not configured'
  end
end
