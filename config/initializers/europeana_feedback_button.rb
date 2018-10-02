# frozen_string_literal: true

# Set the recipient of emails containing feedback submissions
# Europeana::FeedbackButton.mail_to = 'feedback@example.org'
Europeana::FeedbackButton.mail_to = ENV['FEEDBACK_MAIL_TO']
