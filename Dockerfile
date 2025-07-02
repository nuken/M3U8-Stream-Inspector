# Use the official lightweight Alpine Linux as a base image
FROM alpine:latest

# Install the necessary tools. 
# We install 'bash' since Alpine's default shell is 'ash'.
# 'gawk' is used for better compatibility than the default awk.
RUN apk update && apk add --no-cache bash curl gawk

# Copy the bash script from your host into the container's root directory
COPY inspect_m3u8.sh /inspect_m3u8.sh

# Make the script executable inside the container
RUN chmod +x /inspect_m3u8.sh

# Set the script as the command to run when the container starts
ENTRYPOINT ["/inspect_m3u8.sh"]