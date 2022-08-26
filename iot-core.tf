resource "aws_iot_thing" "iot_phone1" {
    name = "phone1"
  
}

resource "aws_iot_topic_rule" "iotSendToKinesisRule" {
    name        = "MyRule"
    description = "Example rule"
    enabled     = true
    sql         = "SELECT * FROM 'topic/test'"
    sql_version = "2016-03-23"

    sns {
        message_format = "RAW"
        role_arn       = aws_iam_role.role.arn
        target_arn     = aws_sns_topic.mytopic.arn
    }

    error_action {
        sns {
        message_format = "RAW"
        role_arn       = aws_iam_role.role.arn
        target_arn     = aws_sns_topic.myerrortopic.arn
        }
    }

}

resource "aws_sns_topic" "mytopic" {
  name = "mytopic"
}

resource "aws_sns_topic" "myerrortopic" {
  name = "myerrortopic"
}

resource "aws_iam_role" "role" {
  name = "myrole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_policy_for_lambda" {
  name = "mypolicy"
  role = aws_iam_role.role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "sns:Publish"
        ],
        "Resource": "${aws_sns_topic.mytopic.arn}"
    }
  ]
}
EOF
}



# X.509 client certificates

# X.509 certificates provide AWS IoT with the ability to authenticate client and device connections. Client certificates must be registered with AWS IoT before a client can communicate with AWS IoT.

# Tagging your AWS IoT resources

# Authorization
# Authorization is the process of granting permissions to an authenticated identity. You grant permissions in AWS IoT Core using AWS IoT Core and IAM policies.
# AWS IoT Core policies determine what an authenticated identity can do. An authenticated identity is used by devices, mobile applications, web applications, and desktop applications. 

# Transport security in AWS IoT
# The AWS IoT message broker and Device Shadow service encrypt all communication while in-transit by using TLS version 1.2. TLS is used to ensure the confidentiality of the application protocols (MQTT, HTTP, and WebSocket) supported by AWS IoT.
# Connections attempted by devices without the correct host_name value will fail, and AWS IoT will log failures to CloudWatch if the authentication type is Custom Authentication.


# Data encryption in AWS IoT
# Data protection refers to protecting data while in-transit (as it travels to and from AWS IoT) and at rest (while it is stored on devices or by other AWS services). All data sent to AWS IoT is sent over an TLS connection using MQTT, HTTPS, and WebSocket protocols, making it secure by default while in transit. AWS IoT devices collect data and then send it to other AWS services for further processing. 

# Key management in AWS IoT
# All connections to AWS IoT are done using TLS, so no client-side encryption keys are necessary for the initial TLS connection.

# Devices must authenticate using an X.509 certificate or an Amazon Cognito Identity. You can have AWS IoT generate a certificate for you, in which case it will generate a public/private key pair. 

# Security monitoring
# You can use AWS IoT Device Defender to analyze, audit, and monitor connected devices to detect abnormal behavior, and mitigate security risks. AWS IoT Device Defender can audit device fleets to ensure they adhere to security best practices and detect abnormal behavior on devices. This makes it possible to enforce consistent security policies across your AWS IoT device fleet and respond quickly when devices are compromised.

