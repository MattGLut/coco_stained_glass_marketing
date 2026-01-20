# frozen_string_literal: true

# This file should ensure the existence of records required to run the application.
# It is idempotent, so it's safe to run multiple times.

puts "Seeding database..."

# Create admin user (Coco)
admin = User.find_or_create_by!(email: "coco@stainedglass.com") do |user|
  user.first_name = "Coco"
  user.last_name = "Glass"
  user.password = "adminpassword123"
  user.password_confirmation = "adminpassword123"
  user.role = :admin
  user.confirmed_at = Time.current
end
puts "✓ Admin user created: #{admin.email}"

# Create sample customer
customer = User.find_or_create_by!(email: "customer@example.com") do |user|
  user.first_name = "Sample"
  user.last_name = "Customer"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :customer
  user.confirmed_at = Time.current
end
puts "✓ Sample customer created: #{customer.email}"

# Create categories
categories = [
  { name: "Windows", description: "Stained glass windows for homes and churches" },
  { name: "Panels", description: "Decorative hanging panels" },
  { name: "Lamps", description: "Tiffany-style lamps and lighting" },
  { name: "Mirrors", description: "Decorative mirrors with stained glass borders" },
  { name: "Custom", description: "Custom commissioned pieces" }
]

categories.each_with_index do |cat_attrs, index|
  Category.find_or_create_by!(name: cat_attrs[:name]) do |category|
    category.description = cat_attrs[:description]
    category.position = index
  end
end
puts "✓ #{categories.size} categories created"

# Create sample works
works = [
  { title: "Sunrise Over the Valley", description: "A vibrant sunrise captured in warm oranges, yellows, and pinks.", year_created: 2024, featured: true },
  { title: "Ocean Waves", description: "Cascading blue and teal waves in motion.", year_created: 2023, featured: true },
  { title: "Forest Canopy", description: "Dappled sunlight through green leaves.", year_created: 2024, featured: true },
  { title: "Abstract Geometry", description: "Bold geometric shapes in jewel tones.", year_created: 2023 },
  { title: "Mountain Reflection", description: "Purple mountains reflected in a calm lake.", year_created: 2022 },
  { title: "Wildflower Garden", description: "A colorful arrangement of wildflowers.", year_created: 2024 }
]

categories_for_assignment = Category.all.to_a
works.each_with_index do |work_attrs, index|
  work = Work.find_or_create_by!(title: work_attrs[:title]) do |w|
    w.description = work_attrs[:description]
    w.year_created = work_attrs[:year_created]
    w.featured = work_attrs[:featured] || false
    w.published = true
    w.dimensions = "#{rand(12..48)}\" x #{rand(12..48)}\""
    w.medium = ["Stained glass, lead came", "Stained glass, copper foil", "Fused glass"].sample
    w.position = index
  end
  
  # Assign random categories
  work.categories = categories_for_assignment.sample(rand(1..2)) if work.categories.empty?
end
puts "✓ #{works.size} sample works created"

# Create sample commission for the customer
commission = Commission.find_or_create_by!(user: customer, title: "Custom Kitchen Window") do |c|
  c.description = "A custom stained glass window for above the kitchen sink, featuring herbs and flowers."
  c.customer_notes = "I'd love to see rosemary, basil, and lavender incorporated."
  c.dimensions = "24\" x 18\""
  c.location = "Kitchen, above sink"
  c.status = "in_progress"
  c.estimated_price = 1200.00
  c.deposit_amount = 300.00
  c.deposit_paid = true
  c.deposit_paid_at = 2.weeks.ago.to_date
  c.estimated_start_date = 1.week.ago.to_date
  c.actual_start_date = 5.days.ago.to_date
  c.estimated_completion_date = 3.weeks.from_now.to_date
end

# Create sample updates
[
  { title: "Design approved!", body: "We've finalized the design with your requested herbs. Starting glass selection this week.", days_ago: 5 },
  { title: "Glass selection complete", body: "Found beautiful greens and purples for the herbs. The lavender glass has a lovely iridescent quality.", days_ago: 3 },
  { title: "Cutting in progress", body: "All pieces are cut and ready for grinding. Making great progress!", days_ago: 1 }
].each do |update_attrs|
  CommissionUpdate.find_or_create_by!(commission: commission, title: update_attrs[:title]) do |update|
    update.body = update_attrs[:body]
    update.user = admin
    update.notify_customer = false # Don't send emails during seeding
    update.created_at = update_attrs[:days_ago].days.ago
  end
end
puts "✓ Sample commission with updates created"

puts "\n✅ Seeding complete!"
puts "\nYou can sign in with:"
puts "  Admin:    coco@stainedglass.com / adminpassword123"
puts "  Customer: customer@example.com / password123"
