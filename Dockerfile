FROM golang:1.22-alpine

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY ${PWD} /app

# Download all dependencies.
RUN go mod download

# Build the binary.
RUN go build -o /crypto-exchange

# Run backend on port 8080
EXPOSE 8080

# Run the web service on container startup.
CMD ["/crypto-exchange"]
