RSpec.describe FeedbackController do
  describe 'POST create' do
    let(:params) { { locale: 'en', type: 'comment', text: 'This is good!', url: home_url(locale: 'en') } }
    subject { post :create, params }

    context 'with recipient configured' do
      before do
        Rails.application.config.x.feedback_mail_to = 'feedback@example.com'
      end

      it 'should queue an email job' do
        expect { subject }.to change { Delayed::Job.where("handler LIKE '%FeedbackMailer%'").count }.by(1)
      end
    end

    context 'without recipient configured' do
      before do
        Rails.application.config.x.feedback_mail_to = nil
      end

      it 'should not queue an email job' do
        expect { subject }.to_not change { Delayed::Job.where("handler LIKE '%FeedbackMailer%'").count }
      end
    end
  end
end
