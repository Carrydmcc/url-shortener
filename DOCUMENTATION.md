# ShipUrlShortener - Configuration Documentation

This documentation provides detailed information on configuring and deploying the ShipUrlShortener service based on the Shipa Delivery infrastructure.

## Table of Contents

- [Quick Start](#quick-start)
- [Environment Variables](#environment-variables)
  - [Core Settings](#core-settings)
  - [Database Configuration](#database-configuration)
  - [Link Generation](#link-generation)
  - [Redis Cache](#redis-cache)
  - [Email & Reporting](#email--reporting)
  - [Domain Settings](#domain-settings)
  - [Multi-Instance Configuration](#multi-instance-configuration)
- [Database Setup](#database-setup)
- [Docker Deployment](#docker-deployment)
- [Production Checklist](#production-checklist)

---

## Quick Start

1. Copy the example environment file:
   ```bash
   cp .shipa-example.env .env
   ```

2. Update the required variables in `.env`:
   - `JWT_SECRET` - Generate a long random string
   - Database credentials (`DB_HOST`, `DB_PASSWORD`, etc.)
   - Redis connection details (if enabled)

3. Initialize the database:
   ```bash
   npm run migrate
   ```

4. Start the application:
   ```bash
   npm start
   ```

---

## Environment Variables

### Core Settings

#### `PORT`
- **Description**: The port number the application listens on
- **Default**: `5535`
- **Example**: `PORT=8080`
- **Notes**: Make sure this port is not already in use by another service

#### `SITE_NAME`
- **Description**: The name of your URL shortener service displayed throughout the UI
- **Default**: `ShipUrlShortener`
- **Example**: `SITE_NAME=Shipa Link Shortener`
- **Notes**: Used in page titles, headers, and email templates

#### `JWT_SECRET`
- **Description**: Secret key used to sign and verify JWT authentication tokens
- **Default**: `flfwmgoper423fbejboergp4t4` (example only)
- **Example**: `JWT_SECRET=your-super-long-random-secret-key-here-at-least-32-chars`
- **⚠️ CRITICAL**: 
  - Must be changed in production
  - Use a cryptographically secure random string (minimum 32 characters)
  - Generate with: `openssl rand -base64 32`
  - Never commit this to version control

---

### Database Configuration

The application uses MySQL2 driver by default (configured for bl-delivery infrastructure).

#### `DB_CLIENT`
- **Description**: Database driver to use
- **Default**: `mysql2`
- **Options**: 
  - `mysql2` - MySQL/MariaDB
  - `pg` - PostgreSQL
  - `better-sqlite3` - SQLite (for development)
- **Example**: `DB_CLIENT=mysql2`
- **Notes**: Currently using MySQL2 on bl-delivery. Change only if migrating to a different database system.

#### `DB_HOST`
- **Description**: Database server hostname or IP address
- **Default**: `a` (placeholder)
- **Example**: `DB_HOST=mysql.shipa.internal` or `DB_HOST=10.0.1.50`
- **Notes**: 
  - For Docker: Use service name from docker-compose (e.g., `mysql`)
  - For local dev with Docker: Use `host.docker.internal`
  - For production: Use internal network hostname or IP

#### `DB_PORT`
- **Description**: Database server port
- **Default**: `3306` (MySQL default)
- **Example**: `DB_PORT=3306`
- **Notes**: Standard MySQL port is 3306, PostgreSQL is 5432

#### `DB_NAME`
- **Description**: Database name
- **Default**: `kutt-shortener`
- **Example**: `DB_NAME=shipa_url_shortener`
- **Notes**: Database must be created before running migrations

#### `DB_USER`
- **Description**: Database username
- **Default**: `kutt_user`
- **Example**: `DB_USER=shipa_app_user`
- **Notes**: User must have full permissions on the database

#### `DB_PASSWORD`
- **Description**: Database password
- **Default**: `guessme` (example only)
- **Example**: `DB_PASSWORD=your-secure-database-password`
- **⚠️ CRITICAL**: 
  - Change this in production
  - Use a strong, unique password
  - Never commit to version control

#### `DB_SSL`
- **Description**: Enable SSL/TLS for database connections
- **Default**: `false`
- **Example**: `DB_SSL=true`
- **Notes**: Set to `true` if your database requires encrypted connections

#### `DB_POOL_MIN`
- **Description**: Minimum number of database connections to maintain in the pool
- **Default**: `1`
- **Example**: `DB_POOL_MIN=2`
- **Notes**: Lower values reduce idle resource usage

#### `DB_POOL_MAX`
- **Description**: Maximum number of database connections allowed in the pool
- **Default**: `30`
- **Example**: `DB_POOL_MAX=50`
- **Notes**: 
  - Higher values support more concurrent requests
  - Should be less than your database's max_connections limit
  - Consider your server's memory when setting this

---

### Link Generation

#### `LINK_LENGTH`
- **Description**: Length of generated short URL identifiers
- **Default**: `8`
- **Example**: `LINK_LENGTH=6`
- **Notes**: 
  - With alphabet of 59 chars and length 8: ~59^8 = 128 trillion possible combinations
  - Longer = more combinations but longer URLs
  - Recommended: 6-8 characters

#### `LINK_CUSTOM_ALPHABET`
- **Description**: Character set used to generate short URL identifiers
- **Default**: `abcdefghkmnpqrstuvwxyzABCDEFGHKLMNPQRSTUVWXYZ23456789`
- **Example**: `LINK_CUSTOM_ALPHABET=0123456789abcdefghijklmnopqrstuvwxyz`
- **Notes**: 
  - Default alphabet omits confusing characters: `o`, `O`, `0`, `i`, `I`, `l`, `1`, `j`
  - This prevents confusion when manually typing URLs
  - Total 59 characters in default set
  - Do NOT change after links are created (will break existing links)

---

### Redis Cache

Redis is used for caching and rate limiting to improve performance.

#### `REDIS_ENABLED`
- **Description**: Enable or disable Redis caching
- **Default**: `true`
- **Example**: `REDIS_ENABLED=false`
- **Notes**: 
  - Recommended for production environments
  - If disabled, the app will still work but without caching benefits

#### `REDIS_HOST`
- **Description**: Redis server hostname or IP address
- **Default**: `` (empty - needs configuration)
- **Example**: `REDIS_HOST=redis.shipa.internal` or `REDIS_HOST=127.0.0.1`
- **Notes**: 
  - For Docker: Use service name from docker-compose (e.g., `redis`)
  - For local dev with Docker: Use `host.docker.internal`

#### `REDIS_PORT`
- **Description**: Redis server port
- **Default**: `6379` (Redis default)
- **Example**: `REDIS_PORT=6379`
- **Notes**: Standard Redis port

#### `REDIS_PASSWORD`
- **Description**: Redis authentication password
- **Default**: `` (empty - no auth)
- **Example**: `REDIS_PASSWORD=your-redis-password`
- **Notes**: 
  - Leave empty if Redis doesn't require authentication
  - Use a strong password in production

#### `REDIS_DB`
- **Description**: Redis database number (0-15)
- **Default**: `2`
- **Example**: `REDIS_DB=3`
- **Notes**: 
  - Use different database numbers to isolate data from other Shipa services
  - Default is 2 because 0 is occupied by other Shipa services
  - Valid range: 0-15

---

### Email & Reporting

#### `REPORT_EMAIL`
- **Description**: Email address that receives user-submitted reports
- **Default**: `vvengrov@shipadelivery.com`
- **Example**: `REPORT_EMAIL=abuse@shipadelivery.com`
- **Notes**: 
  - Users can report malicious or inappropriate links
  - Make sure this email is monitored
  - Update to appropriate support email for your organization

---

### Domain Settings

#### `CUSTOM_DOMAIN_USE_HTTPS`
- **Description**: Use HTTPS for links with custom domains
- **Default**: `true`
- **Example**: `CUSTOM_DOMAIN_USE_HTTPS=false`
- **Notes**: 
  - Set to `true` to generate HTTPS links for custom domains
  - You are responsible for SSL certificate management for custom domains
  - Recommended for production

---

### Multi-Instance Configuration

#### `NODE_APP_INSTANCE`
- **Description**: Instance identifier when running multiple instances of the service
- **Default**: `0`
- **Example**: `NODE_APP_INSTANCE=1`
- **Notes**: 
  - If running a single instance: Set to `0`
  - If running multiple instances (load balanced):
    - First instance: `NODE_APP_INSTANCE=0`
    - Second instance: `NODE_APP_INSTANCE=1`
    - And so on...
  - Used for coordinating scheduled tasks across instances
  - Only the instance with value `0` runs cron jobs

---

## Database Setup

### Creating the Database

Before running migrations, create the database:

**MySQL:**
```sql
CREATE DATABASE `kutt-shortener` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'kutt_user'@'%' IDENTIFIED BY 'your-secure-password';
GRANT ALL PRIVILEGES ON `kutt-shortener`.* TO 'kutt_user'@'%';
FLUSH PRIVILEGES;
```

### Running Migrations

Initialize the database schema:

```bash
npm run migrate
```

This will create all necessary tables and indexes.

### Database Schema

The application creates the following tables:
- `users` - User accounts
- `domains` - Custom domains
- `links` - Shortened URLs
- `visits` - Visit statistics
- `hosts` - Banned/allowed hosts
- `ips` - IP address tracking

---

## Docker Deployment

### Building the Image

Build the Docker image:

```bash
npm run docker:build
```

**Prerequisites:**
- Install `cross-conf-env`: `npm install --save-dev cross-conf-env`
- Configure `imageRepo` in `package.json`:
  ```json
  "config" : {
    "imageRepo": "registry.shipa.internal/url-shortener",
    "imageName": "url-shortener"
  }
  ```

### Running with Docker

**Using docker-compose:**

```bash
docker-compose up -d
```

**Using npm scripts:**

```bash
npm run docker:run
```

### Docker Environment Variables

When running in Docker, make sure to:
1. Use `--env-file .env` to load environment variables
2. Set `DB_HOST` to the database container name or `host.docker.internal`
3. Set `REDIS_HOST` to the Redis container name or `host.docker.internal`
4. Expose the port: `-p 5535:5535`

**Example:**
```bash
docker run -p 5535:5535 --env-file .env \
  --name url-shortener \
  registry.shipa.internal/url-shortener:latest
```

---

## Production Checklist

Before deploying to production, verify:

### Security
- [ ] `JWT_SECRET` changed from example value
- [ ] `DB_PASSWORD` is a strong, unique password
- [ ] `REDIS_PASSWORD` is set (if Redis requires auth)
- [ ] Environment variables are not committed to version control
- [ ] SSL/TLS enabled for database (`DB_SSL=true`) if required
- [ ] HTTPS enabled for custom domains (`CUSTOM_DOMAIN_USE_HTTPS=true`)

### Configuration
- [ ] `SITE_NAME` set to appropriate value
- [ ] `REPORT_EMAIL` configured and monitored
- [ ] Database credentials are correct
- [ ] Redis connection is configured (if enabled)
- [ ] Port is not conflicting with other services

### Database
- [ ] Database created with UTF-8 encoding
- [ ] Database user has correct permissions
- [ ] Migrations have been run successfully
- [ ] Database backups are configured

### Performance
- [ ] `DB_POOL_MAX` configured based on expected load
- [ ] Redis enabled for caching (`REDIS_ENABLED=true`)
- [ ] Appropriate `LINK_LENGTH` chosen (6-8 recommended)

### Multi-Instance
- [ ] `NODE_APP_INSTANCE` set correctly for each instance
- [ ] Only one instance has `NODE_APP_INSTANCE=0` (for cron jobs)
- [ ] Load balancer configured (if applicable)

### Monitoring
- [ ] Health check endpoint is monitored (`/health`)
- [ ] Database connection monitoring
- [ ] Redis connection monitoring
- [ ] Application logs are being collected

---

## Troubleshooting

### Common Issues

**Database connection refused:**
- Check `DB_HOST` is correct (use `host.docker.internal` for local Docker)
- Verify database is running
- Confirm firewall rules allow connection on `DB_PORT`

**Redis connection failed:**
- Check `REDIS_HOST` is correct
- Verify Redis is running
- Check `REDIS_PASSWORD` if authentication is enabled

**Migrations fail:**
- Ensure database exists and user has permissions
- Check database encoding is UTF-8
- Verify connection parameters are correct
---

## Support

For issues or questions:
- Email: vvengrov@shipadelivery.com

---

*Last updated: January 2026*

