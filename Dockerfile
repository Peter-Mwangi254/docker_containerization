# Stage 1: Builder - install dependencies and prepare the application
FROM python:3.12-slim AS builder

WORKDIR /app

# Copy and install Python dependencies into /app/deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target /app/deps

# Copy the rest of the application code
COPY . .

# Stage 2: Final Image - Use a Distroless Python image for a smaller, safer container
FROM gcr.io/distroless/python3

WORKDIR /app

# Copy the application and installed dependencies from the builder stage
COPY --from=builder /app /app

# Set the PYTHONPATH so Python can find the installed dependencies
ENV PYTHONPATH="/app/deps"

# Expose the port your application listens on
EXPOSE 8080

# Let the default entrypoint (Python) run your manage.py script with arguments.
CMD ["manage.py", "runserver", "0.0.0.0:8080"]
