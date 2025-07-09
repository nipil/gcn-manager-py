FROM debian:12-slim AS build
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip setuptools wheel

# Build the virtualenv as a separate step: Only re-execute this step when requirements.txt changes
FROM build AS build-venv
ARG GCN_MANAGER_VERSION
RUN /venv/bin/pip install --disable-pip-version-check gcn-manager==${GCN_MANAGER_VERSION}

# Copy the virtualenv into a distroless image
FROM gcr.io/distroless/python3-debian12:nonroot
COPY --from=build-venv /venv /venv
ENTRYPOINT ["/venv/bin/python3", "-m", "gcn_manager"]
