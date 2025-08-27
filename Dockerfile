FROM node:20-alpine AS builder

WORKDIR /app

# Install necessary build dependencies for Alpine Linux
RUN apk add --no-cache python3 make g++

COPY package.json package-lock.json* ./

# Force clean install to ensure proper optional dependency resolution
RUN rm -rf node_modules package-lock.json && npm install --prefer-offline --no-audit

# Copy source code
COPY . .

RUN npm run build --omit=dev

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 5173

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
