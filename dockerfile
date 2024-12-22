# Use the official Elixir image from the Docker Hub
FROM elixir:1.15-alpine AS builder

# Install dependencies for Elixir (and Node.js if needed for assets)
RUN apk add --no-cache build-base git

# Set the working directory inside the container
WORKDIR /app

# Copy the mix.exs and mix.lock to fetch dependencies first
COPY mix.exs mix.lock ./

# Install mix dependencies
RUN mix deps.get

# Copy the rest of the application code
COPY . .

# Build the project (optional: this can be skipped if you don't need to precompile)
RUN mix compile

# Use the official Elixir runtime image to run the app
FROM elixir:1.15-alpine

# Set the working directory for the runtime container
WORKDIR /app

# Copy compiled files and dependencies from the builder stage
COPY --from=builder /app /app

# Expose the application port (adjust if needed)
EXPOSE 8080

# Command to start the Plug app
CMD ["mix", "run", "--no-halt"]
