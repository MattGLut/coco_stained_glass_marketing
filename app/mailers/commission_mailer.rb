# frozen_string_literal: true

class CommissionMailer < ApplicationMailer
  def update_notification(commission_update)
    @update = commission_update
    @commission = commission_update.commission
    @customer = @commission.user

    mail(
      to: @customer.email,
      subject: "Update on your commission: #{@commission.title}"
    )
  end

  def status_changed(commission, previous_status)
    @commission = commission
    @customer = commission.user
    @previous_status = previous_status

    mail(
      to: @customer.email,
      subject: "Your commission status has been updated: #{@commission.status_label}"
    )
  end

  def quote_provided(commission)
    @commission = commission
    @customer = commission.user

    mail(
      to: @customer.email,
      subject: "Your quote is ready: #{@commission.title}"
    )
  end

  def commission_completed(commission)
    @commission = commission
    @customer = commission.user

    mail(
      to: @customer.email,
      subject: "Your commission is complete! #{@commission.title}"
    )
  end
end
