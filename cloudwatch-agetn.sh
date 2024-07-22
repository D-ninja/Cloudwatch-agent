#!/bin/bash

# Function to install and configure CloudWatch Agent for Ubuntu
install_ubuntu() {
    echo "Installing CloudWatch Agent on Ubuntu..."

    # Update package list and install prerequisites
    sudo apt-get update
    sudo apt-get install -y wget

    # Download and install the CloudWatch Agent
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i amazon-cloudwatch-agent.deb
    rm amazon-cloudwatch-agent.deb

    # Create CloudWatch Agent configuration file
    cat <<EOL | sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "metrics": {
        "append_dimensions": {
            "InstanceId": "\${aws:InstanceId}"
        },
        "metrics_collected": {
            "mem": {
                "metrics_collection_interval": 60
            }
        }
    }
}
EOL

    # Start the CloudWatch Agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start
}

# Function to install and configure CloudWatch Agent for Amazon Linux
install_amazon_linux() {
    echo "Installing CloudWatch Agent on Amazon Linux..."

    # Download and install the CloudWatch Agent
    sudo yum install -y amazon-cloudwatch-agent

    # Create CloudWatch Agent configuration file
    cat <<EOL | sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "metrics": {
        "append_dimensions": {
            "InstanceId": "\${aws:InstanceId}"
        },
        "metrics_collected": {
            "mem": {
                "metrics_collection_interval": 60
            }
        }
    }
}
EOL

    # Start the CloudWatch Agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start
}

# Function to install and configure CloudWatch Agent for RHEL
install_rhel() {
    echo "Installing CloudWatch Agent on RHEL..."

    # Download and install the CloudWatch Agent
    sudo yum install -y amazon-cloudwatch-agent

    # Create CloudWatch Agent configuration file
    cat <<EOL | sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "metrics": {
        "append_dimensions": {
            "InstanceId": "\${aws:InstanceId}"
        },
        "metrics_collected": {
            "mem": {
                "metrics_collection_interval": 60
            }
        }
    }
}
EOL

    # Start the CloudWatch Agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start
}

# Determine OS and call the appropriate function
if [ -f /etc/lsb-release ]; then
    # Ubuntu or Debian
    install_ubuntu
elif [ -f /etc/system-release ]; then
    # Amazon Linux or RHEL
    if grep -qi "Amazon Linux" /etc/system-release; then
        install_amazon_linux
    else
        install_rhel
    fi
else
    echo "Unsupported operating system. Exiting."
    exit 1
fi

echo "CloudWatch Agent installation and configuration complete."

# Check the status of the CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
