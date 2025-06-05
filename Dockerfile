FROM python:3.11-slim

WORKDIR /app

# Install essential packages and dependencies needed for Playwright
RUN apt update && apt install -y \
    curl

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright system dependencies as root
RUN python -m playwright install-deps

# Create a non-root user to run the app
RUN adduser --disabled-password --gecos "" appuser
# Give appuser permissions to the necessary directories
RUN chown -R appuser:appuser /app

USER appuser

# Create a data directory with proper permissions
RUN mkdir -p /app/data && chmod 777 /app/data
RUN mkdir -p /app/media && chmod 777 /app/media

# Install Playwright browsers as appuser (without system deps)
RUN python -m playwright install chromium

# Expose the port the app runs on
EXPOSE 8000

# Copy the rest of the application
COPY . .

# Set healthcheck to ensure the service is running properly
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:8000/api/v1/ping || exit 1

# Command to run the application
CMD ["python", "app.py"]
