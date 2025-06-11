# always run this in case you update lambda/index.js

# cd /home/ali/all-dev/PHASE 3/IAC/terraform/modules/sonarqube/lambda

#  and run .IAC/terraform/modules/sonarqube/lambda/package.sh

#!/bin/bash

# Create a temporary directory
mkdir -p temp

# Copy the Lambda function code
cp index.js temp/

# Install dependencies
cd temp
npm init -y
npm install aws-sdk

# Create the ZIP file
zip -r ../update_route53.zip .

# Clean up
cd ..
rm -rf temp 