# Use the official uv image with Python 3.9 (matches requires-python in pyproject.toml)
FROM ghcr.io/astral-sh/uv:python3.9-bookworm-slim

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # Compile bytecode for faster startup and use copy mode for the mounted volume
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# Install dependencies first (leveraging Docker layer caching).
# Copy only the lockfile and project metadata so this layer is cached
# until dependencies actually change.
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

# Copy the rest of the application source code
COPY . .

# Install the project itself
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Make sure the virtual environment binaries are on the PATH
ENV PATH="/app/.venv/bin:$PATH"

# Run the application
CMD ["python", "main.py"]

