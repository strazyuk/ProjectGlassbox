# 1. Use an official Python base image
FROM python:3.12-slim

# 2. Set the working directory inside the container
# All subsequent commands will run inside this folder
WORKDIR /app

# 3. Set environment variables to keep Python behavior clean in Docker
# Prevents Python from writing .pyc files and ensures output is sent straight to the logs
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 4. Copy only the requirements file first
# This is a 'trick' to speed up future builds by caching the 'pip install' step
COPY requirements.txt .

# 5. Upgrade pip and setuptools, and ensure ecdsa is patched
# hadolint ignore=DL3013
RUN pip install --no-cache-dir --upgrade pip setuptools ecdsa \
    && pip install --no-cache-dir -r requirements.txt

# 6. Copy the rest of your application code into the container
COPY . .

# 7. Inform Docker that the app will listen on port 8000
EXPOSE 8000

# 8. Define the command to run your app
# 0.0.0.0 allows the app to be accessible from outside the container
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
