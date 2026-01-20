# frozen_string_literal: true

class CreateCommissions < ActiveRecord::Migration[8.1]
  def change
    # Commissions table for customer projects
    create_table :commissions do |t|
      t.references :user, null: false, foreign_key: true
      
      # Basic info
      t.string :title, null: false
      t.text :description
      t.text :customer_notes      # Notes from customer about their vision
      t.text :internal_notes      # Admin-only notes
      
      # Status tracking (AASM)
      t.string :status, default: "inquiry", null: false
      
      # Timeline
      t.date :estimated_start_date
      t.date :estimated_completion_date
      t.date :actual_start_date
      t.date :actual_completion_date
      t.date :delivered_at
      
      # Pricing
      t.decimal :estimated_price, precision: 10, scale: 2
      t.decimal :final_price, precision: 10, scale: 2
      t.decimal :deposit_amount, precision: 10, scale: 2
      t.boolean :deposit_paid, default: false
      t.date :deposit_paid_at
      
      # Dimensions & specifications
      t.string :dimensions
      t.string :location           # Where it will be installed
      
      t.timestamps
    end

    add_index :commissions, :status
    add_index :commissions, :created_at

    # Commission updates for progress timeline
    create_table :commission_updates do |t|
      t.references :commission, null: false, foreign_key: true
      t.references :user, foreign_key: true  # Admin who posted the update
      
      t.string :title, null: false
      t.text :body
      t.boolean :notify_customer, default: true
      t.boolean :visible_to_customer, default: true
      
      t.timestamps
    end

    add_index :commission_updates, :created_at
  end
end
