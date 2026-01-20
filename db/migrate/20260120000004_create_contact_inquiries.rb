# frozen_string_literal: true

class CreateContactInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_inquiries do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :subject
      t.text :message, null: false
      t.string :status, default: "new", null: false
      t.text :admin_notes
      t.datetime :responded_at

      t.timestamps
    end

    add_index :contact_inquiries, :status
    add_index :contact_inquiries, :created_at
    add_index :contact_inquiries, :email
  end
end
