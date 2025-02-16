# Dockerfile
FROM ruby:3.2-slim

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and install dependencies
COPY Gemfile* .
RUN bundle install

# Copy application files
COPY . .

# Expose port
EXPOSE 4567

# Start the application
CMD ["ruby", "app.rb", "-o", "0.0.0.0"]