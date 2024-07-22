#!/bin/bash

install_ubuntu() {
    echo "Installing CloudWatch Agent on Ubuntu..."

    sudo apt-get update
    sudo apt-get install -y wget

    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i amazon-cloudwatch-agent.deb
    rm amazon-cloudwatch-agent.deb

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
    sudo systemctl enable amazon-cloudwatch-agent
    sudo systemctl start amazon-cloudwatch-agent
}

install_amazon_linux() {
    echo "Installing CloudWatch Agent on Amazon Linux..."

    sudo yum install -y amazon-cloudwatch-agent

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

    sudo systemctl enable amazon-cloudwatch-agent
    sudo systemctl start amazon-cloudwatch-agent
}

install_rhel() {
    echo "Installing CloudWatch Agent on RHEL..."

    sudo yum install -y amazon-cloudwatch-agent

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

    sudo systemctl enable amazon-cloudwatch-agent
    sudo systemctl start amazon-cloudwatch-agent
}

if [ -f /etc/lsb-release ]; then
    install_ubuntu
elif [ -f /etc/system-release ]; then
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
