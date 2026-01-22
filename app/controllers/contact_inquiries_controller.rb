# frozen_string_literal: true

class ContactInquiriesController < ApplicationController
  def new
    @contact_inquiry = ContactInquiry.new
    authorize @contact_inquiry

    set_meta_tags(
      title: "Contact",
      description: "Get in touch with CMB Glass & Stone in Nashville, TN. Commission a custom piece or ask about our handcrafted stained glass art."
    )
  end

  def create
    @contact_inquiry = ContactInquiry.new(contact_inquiry_params)
    authorize @contact_inquiry

    if @contact_inquiry.save
      redirect_to contact_path, notice: "Thank you for your message! We'll be in touch soon."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def contact_inquiry_params
    params.require(:contact_inquiry).permit(:name, :email, :phone, :subject, :message)
  end
end
