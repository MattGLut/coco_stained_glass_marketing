# Coco's Stained Glass Marketing Site

A Ruby on Rails marketing website for a stained glass artisan business featuring a portfolio gallery, customer commission tracking portal, contact system, and comprehensive SEO optimization.

## Features

### Public Site
- **Portfolio Gallery** — Showcase stained glass works with filtering by category
- **Individual Work Pages** — Detailed pages with images, descriptions, and SEO-optimized metadata
- **About Page** — Business story and craft process
- **Contact Form** — Inquiry form with SendGrid email delivery

### Customer Portal
- **Commission Tracking** — Customers can view their project progress
- **Timeline Updates** — See progress photos and status updates
- **Project Details** — View pricing, timelines, and specifications

### Admin Panel
- **Works Management** — CRUD for portfolio pieces with image uploads
- **Category Management** — Organize works into categories
- **Commission Management** — Create and manage customer commissions with state machine workflow
- **Contact Inquiries** — View and respond to contact form submissions
- **User Management** — Manage customer accounts

### Technical Features
- **Authentication** — Devise with customer and admin roles
- **State Machine** — AASM for commission workflow (inquiry → completed → delivered)
- **File Storage** — Active Storage with AWS S3 integration
- **Email** — Action Mailer with SendGrid
- **SEO** — Meta tags, Open Graph, structured data (JSON-LD), dynamic sitemap
- **Monitoring** — Rollbar error tracking, New Relic APM
- **Testing** — RSpec, FactoryBot, Capybara

## Tech Stack

- Ruby 3.3.0
- Rails 8.1.2
- PostgreSQL
- Hotwire (Turbo + Stimulus)
- Propshaft (Asset Pipeline)
- Devise (Authentication)
- AASM (State Machine)
- Pundit (Authorization)
- AWS S3 (File Storage)
- SendGrid (Email)
- Rollbar (Error Tracking)
- New Relic (APM)

## Getting Started

### Prerequisites
- Ruby 3.3.0
- PostgreSQL
- Node.js (for JavaScript bundling)

### Setup

```bash
# Clone and navigate to project
cd marketing

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start the server
rails server
```

### Environment Variables

Copy `config/env.example` to `.env` and configure:

```bash
# Database
DATABASE_URL=postgres://...

# AWS S3
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_REGION=us-east-1
AWS_BUCKET=stained-glass-production

# SendGrid
SENDGRID_API_KEY=SG.xxx
SENDGRID_DOMAIN=yourdomain.com

# Monitoring
ROLLBAR_ACCESS_TOKEN=xxx
NEW_RELIC_LICENSE_KEY=xxx

# Application
APP_HOST=https://yourdomain.com
DEFAULT_FROM_EMAIL=hello@yourdomain.com
ADMIN_EMAIL=admin@yourdomain.com
```

### Default Credentials (Development)

After running seeds:
- **Admin:** coco@stainedglass.com / adminpassword123
- **Customer:** customer@example.com / password123

## Testing

```bash
# Run full test suite
bundle exec rspec

# Run specific tests
bundle exec rspec spec/models
bundle exec rspec spec/requests
bundle exec rspec spec/system

# With coverage (optional)
COVERAGE=true bundle exec rspec
```

## Deployment

The app is configured for deployment with Kamal. Update `config/deploy.yml` with your server details.

```bash
# Deploy
bin/kamal deploy

# Or use Docker directly
docker build -t stained-glass .
docker run -p 3000:3000 stained-glass
```

### AWS Setup Checklist

1. Create S3 bucket for file storage
2. Create IAM user with S3 access
3. Configure CORS on S3 bucket for uploads
4. Set environment variables

### Production Checklist

- [ ] Configure production database credentials
- [ ] Set up S3 bucket and credentials
- [ ] Configure SendGrid API key
- [ ] Set up Rollbar project
- [ ] Configure New Relic
- [ ] Set `SECRET_KEY_BASE` and `RAILS_MASTER_KEY`
- [ ] Enable SSL (`config.force_ssl = true`)
- [ ] Set correct `APP_HOST` for mailer URLs
- [ ] Generate and deploy sitemap
- [ ] Verify robots.txt
- [ ] Add `og-default.jpg` to `app/assets/images/` for social sharing (see below)

### Social Sharing Image

For proper Open Graph/Twitter card previews, add a default image:

1. Create an image (recommended: 1200x630px) named `og-default.jpg`
2. Place it in `app/assets/images/`
3. Update `app/views/layouts/application.html.erb` to include it in the meta tags:

```erb
og: {
  type: "website",
  site_name: "Coco's Stained Glass",
  image: image_url("og-default.jpg")  # Add this line back
},
```

## Project Structure

```
app/
├── controllers/
│   ├── admin/          # Admin panel controllers
│   ├── portal/         # Customer portal controllers
│   ├── users/          # Custom Devise controllers
│   └── ...             # Public controllers
├── models/
│   ├── user.rb         # Devise user with roles
│   ├── work.rb         # Portfolio pieces
│   ├── category.rb     # Work categories
│   ├── commission.rb   # Customer commissions (AASM)
│   └── ...
├── views/
│   ├── layouts/        # Application, admin, portal layouts
│   ├── admin/          # Admin views
│   ├── portal/         # Customer portal views
│   ├── devise/         # Custom auth views
│   └── ...
└── mailers/            # Email templates

spec/
├── factories/          # FactoryBot factories
├── models/             # Model specs
├── requests/           # Controller/request specs
├── system/             # Capybara system tests
└── support/            # Test helpers
```

## Commission Workflow States

```
inquiry → quoted → accepted → deposit_received → in_progress → review → completed → delivered
                                                      ↓
                                                  cancelled
```

## License

Private - All rights reserved.
