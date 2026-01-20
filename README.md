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
- **File Storage** — Active Storage with Tigris (Fly.io S3-compatible storage)
- **Email** — Action Mailer with SendGrid SMTP
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
- Fly.io (Hosting)
- Tigris (File Storage - S3-compatible on Fly.io)
- SendGrid (Transactional Email)
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

### Environment Variables (Local Development)

Copy `config/env.example` to `.env` and configure for local development:

```bash
# Database (optional - defaults to local postgres)
DATABASE_URL=postgres://localhost/stained_glass_development

# SendGrid (optional for local - uses letter_opener by default)
# Only needed if testing actual email delivery locally
SENDGRID_API_KEY=SG.xxx

# Application
APP_HOST=localhost:3000
DEFAULT_FROM_EMAIL=hello@yourdomain.com
ADMIN_EMAIL=admin@yourdomain.com
```

**Note:** In development, emails are captured by `letter_opener` and displayed in the browser instead of being sent. See `config/environments/development.rb`.

For production environment variables, see the [Fly.io Secrets](#flyio-secrets) section below.

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

The app is deployed on **Fly.io** with automatic deploys via GitHub Actions on push to `master`.

### Fly.io Setup

```bash
# Install Fly CLI
# See: https://fly.io/docs/hands-on/install-flyctl/

# Login to Fly
fly auth login

# Launch app (first time only - already configured in fly.toml)
fly launch

# Deploy manually
fly deploy

# View logs
fly logs

# Open remote Rails console
fly ssh console -C "/rails/bin/rails console"
```

### Fly.io Secrets

Set these secrets in your Fly.io app for production:

```bash
# Required for email delivery (contact form, notifications)
fly secrets set SENDGRID_API_KEY=SG.your_api_key_here

# Application settings
fly secrets set APP_HOST=yourdomain.com
fly secrets set DEFAULT_FROM_EMAIL=hello@yourdomain.com
fly secrets set ADMIN_EMAIL=coco@yourdomain.com

# Rails secrets
fly secrets set SECRET_KEY_BASE=$(rails secret)

# Monitoring (optional)
fly secrets set ROLLBAR_ACCESS_TOKEN=xxx
fly secrets set NEW_RELIC_LICENSE_KEY=xxx
```

### SendGrid Setup

The contact form and commission notifications require SendGrid for email delivery:

1. **Create a SendGrid account** at [sendgrid.com](https://sendgrid.com)
2. **Create an API key** with "Mail Send" permissions
3. **Set the secret on Fly.io:**
   ```bash
   fly secrets set SENDGRID_API_KEY=SG.your_api_key_here
   ```
4. **Optional:** Configure a custom sending domain in SendGrid for better deliverability

The free tier (100 emails/day) is sufficient for contact form usage.

**Configuration location:** `config/initializers/sendgrid.rb`

### Tigris Storage (Fly.io)

File uploads use Tigris, Fly.io's S3-compatible object storage:

```bash
# Create Tigris bucket (if not already created)
fly storage create

# The bucket credentials are automatically set as secrets
```

**Configuration location:** `config/storage.yml`

### Production Checklist

- [ ] Configure Fly.io secrets (see above)
- [ ] Set up SendGrid API key for email delivery
- [ ] Create Tigris bucket for file storage
- [ ] Set up Rollbar project (optional)
- [ ] Configure New Relic (optional)
- [ ] Set correct `APP_HOST` for mailer URLs
- [ ] Verify DNS and SSL certificate
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
