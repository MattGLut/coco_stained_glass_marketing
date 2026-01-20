# frozen_string_literal: true

class ContactInquiriesController < ApplicationController
  def new
    @contact_inquiry = ContactInquiry.new

    set_meta_tags(
      title: "Contact",
      description: "Get in touch with Coco's Stained Glass. Inquire about custom commissions, ask questions, or just say hello."
    )
  end

  def create
    @contact_inquiry = ContactInquiry.new(contact_inquiry_params)

    if @contact_inquiry.save
      redirect_to contact_path, notice: "Thank you for your message! We'll be in touch soon."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_inquiry_params
    params.require(:contact_inquiry).permit(:name, :email, :phone, :subject, :message)
  end

  def skip_pundit?
    true
  end
end
