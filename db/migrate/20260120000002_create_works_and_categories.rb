# frozen_string_literal: true

class CreateWorksAndCategories < ActiveRecord::Migration[8.1]
  def change
    # Categories table for organizing works
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :position

    # Works table for portfolio pieces
    create_table :works do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.string :dimensions           # e.g., "24\" x 36\""
      t.string :medium               # e.g., "Stained glass, lead came"
      t.integer :year_created
      t.boolean :featured, default: false
      t.boolean :published, default: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :works, :slug, unique: true
    add_index :works, :featured
    add_index :works, :published
    add_index :works, :position
    add_index :works, :year_created

    # Join table for works and categories (many-to-many)
    create_table :work_categories do |t|
      t.references :work, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :work_categories, [:work_id, :category_id], unique: true
  end
end
