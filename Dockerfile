# 1. Use an official Python base image
FROM python:3.12-slim

# 2. Set the working directory inside the container
WORKDIR /app

# 2.1 Apply targeted security patches for specific OS vulnerabilities (Phase 1)
# hadolint ignore=DL3008,DL3009,DL3015
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --only-upgrade -y \
    libc6 libc-bin libsystemd0 libudev1 \
    && apt-get remove --purge -y ncurses-bin ncurses-base libncursesw6 libtinfo6 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# 3. Set environment variables to keep Python behavior clean in Docker
# Prevents Python from writing .pyc files and ensures output is sent straight to the logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 4. Copy only the requirements file first
# This is a 'trick' to speed up future builds by caching the 'pip install' step
COPY requirements.txt .

# 5. Upgrade pip and setuptools to fix vulnerabilities, then install requirements
# hadolint ignore=DL3013
RUN pip install --no-cache-dir --upgrade pip setuptools \
    && pip install --no-cache-dir -r requirements.txt

# 6. Copy the rest of your application code into the container
COPY . .

# 7. Create a non-privileged user and switch to it for runtime (Phase 5)
RUN useradd -r -u 1001 appuser
USER appuser

# 8. Inform Docker that the app will listen on port 8000
EXPOSE 8000

# 9. Define the command to run your app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
