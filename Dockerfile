# Use official Flutter image
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy all files to container
COPY . .

# Enable web support
RUN flutter config --enable-web

# Get dependencies
RUN flutter pub get

# Build Flutter web app
RUN flutter build web --release

# Tell Vercel which directory to serve
CMD ["cp", "-r", "build/web", "/vercel/output/"]
