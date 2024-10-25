## Install Gcloud

# Install prerequisites
apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg curl

# Add the gcloud repo and key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install gcloud
apt-get update && apt-get install -y google-cloud-sdk

# Verify installation
gcloud --version

