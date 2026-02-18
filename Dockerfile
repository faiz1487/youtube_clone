# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy only dependency files first (for caching)
COPY package*.json ./

# Faster and clean install
RUN npm ci

# Copy rest of the code
COPY . .

# Build the app
RUN npm run build


# Stage 2: Production
FROM node:20-alpine

WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder /app ./

# Expose app port
EXPOSE 3000

# Start app
CMD ["npm", "start"]
