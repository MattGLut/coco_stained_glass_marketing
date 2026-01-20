# frozen_string_literal: true

module Admin
  class ContactInquiriesController < BaseController
    before_action :set_inquiry, only: [:show, :update, :destroy, :mark_responded, :archive]

    def index
      @inquiries = ContactInquiry.recent

      case params[:status]
      when "pending"
        @inquiries = @inquiries.pending
      when "responded"
        @inquiries = @inquiries.responded
      when "archived"
        @inquiries = @inquiries.archived
      end

      set_meta_tags(title: "Contact Inquiries")
    end

    def show
      set_meta_tags(title: "Inquiry from #{@inquiry.name}")
    end

    def update
      if @inquiry.update(inquiry_params)
        redirect_to admin_contact_inquiry_path(@inquiry), notice: "Notes saved."
      else
        render :show, status: :unprocessable_content
      end
    end

    def destroy
      @inquiry.destroy
      redirect_to admin_contact_inquiries_path, notice: "Inquiry deleted."
    end

    def mark_responded
      @inquiry.mark_as_responded!
      redirect_to admin_contact_inquiry_path(@inquiry), notice: "Marked as responded."
    end

    def archive
      @inquiry.mark_as_archived!
      redirect_to admin_contact_inquiries_path, notice: "Inquiry archived."
    end

    private

    def set_inquiry
      @inquiry = ContactInquiry.find(params[:id])
    end

    def inquiry_params
      params.require(:contact_inquiry).permit(:admin_notes)
    end
  end
end
