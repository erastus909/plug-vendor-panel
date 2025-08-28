FROM node:20-alpine AS builder

WORKDIR /app

# Install necessary build dependencies for Alpine Linux
RUN apk add --no-cache python3 make g++

COPY package.json package-lock.json* ./

# Force clean install to ensure proper optional dependency resolution
RUN rm -rf node_modules package-lock.json && npm install --prefer-offline --no-audit

# Copy source code
COPY . .

# Accept build arguments and set them as environment variables
ARG VITE_MEDUSA_BASE
ARG VITE_MEDUSA_STOREFRONT_URL
ARG VITE_MEDUSA_BACKEND_URL
ARG VITE_PUBLISHABLE_API_KEY
ARG VITE_TALK_JS_APP_ID
ARG VITE_DISABLE_SELLERS_REGISTRATION

ENV VITE_MEDUSA_BASE=$VITE_MEDUSA_BASE
ENV VITE_MEDUSA_STOREFRONT_URL=$VITE_MEDUSA_STOREFRONT_URL
ENV VITE_MEDUSA_BACKEND_URL=$VITE_MEDUSA_BACKEND_URL
ENV VITE_PUBLISHABLE_API_KEY=$VITE_PUBLISHABLE_API_KEY
ENV VITE_TALK_JS_APP_ID=$VITE_TALK_JS_APP_ID
ENV VITE_DISABLE_SELLERS_REGISTRATION=$VITE_DISABLE_SELLERS_REGISTRATION

RUN npm run build:preview --omit=dev

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
