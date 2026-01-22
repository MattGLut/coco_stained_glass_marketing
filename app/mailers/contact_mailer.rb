# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def confirmation(inquiry)
    @inquiry = inquiry
    
    mail(
      to: @inquiry.email,
      subject: "Thank you for contacting CMB Glass & Stone"
    )
  end

  def admin_notification(inquiry)
    @inquiry = inquiry
    
    mail(
      to: admin_email,
      subject: "[New Inquiry] #{@inquiry.subject.presence || 'Contact Form Submission'}"
    )
  end
end
