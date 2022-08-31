# Create a thing 
# Create a private key, public key and certificate to authenticate with IoT Core 
# Create an IoT policy for authorization
# Attach policy to the principal (certificate)
# Attach thing to the principal (certificate)
# Create cloudwatch logs with role 
# * Create Create Cognito identity pool 
# Setup the thing 

# MTTQ to Kinesis Data Firehorse Requirements

# 1. An IAM role that Amazon IoT can assume to perform the firehose:PutRecord operation. 
# 2. Since Kinesis Data Firehose will send data to an Amazon S3 bucket,  we'll use Amazon KMS  to encrypt data at rest in Amazon S3, Kinesis Data Firehose must have access to your bucket and permission to use the Amazon KMS key on the caller's behalf. 
# 3. IOT topic rule 

resource "aws_iot_thing" "iot_phone1" {
    name = "phone1"
    # id =  

  
}

# Data Ingestion
# IOT Core configuration 

# Data  from the devices will be sent  using the MQTT protocol to minimize code footprint and network bandwidth. IoT Core can also manage device authentication.
resource "aws_iot_topic_rule" "iotSendToKinesisRule" {
    name        = "${local.project_name}Kinesis"
    description = "Kinesis rule"
    enabled     = true
    sql         = "SELECT * FROM 'topic/${local.iot_topic}'"
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

    kinesis {
      role_arn       = "${aws_iam_role.iot.arn}"
      stream_name = "${aws_kinesis_stream.sensors.name}"
      partition_key = "$${newuuid()}"
    }

    firehose {
      delivery_stream_name = "${aws_kinesis_firehose_delivery_stream.sensors.name}"
      role_arn       = "${aws_iam_role.iot.arn}"
    }

}

# Firehose delivery stream with destination S3 bucket specified

resource "aws_kinesis_firehose_delivery_stream" "delivery stream" {
  name = "${local.project_name}-s3"
  destination = "s3"

  s3_configuration {
    role_arn = "${aws_iam_role.firehorse.arn}"
    bucket_arn = "${aws_s3_bucket.sensor_storage.arn}"
    buffer_size = 5
    buffer_interval = 60
  }
  
}

# S3 bucket and Kinesis Stream policy to allow the execution to access it 

resource "aws_iam_role" "kinesisRole" {
  name = "kinesisRole"
  assume_role_policy = <<EOF

  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource": [
          "${aws_s3_bucket.sensor_storage.arn}",
          "${aws_s3_bucket.sensor_storage.arn}/*"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStreams",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords"
      ],
      "Resource": "${aws_kinesis_stream.sensor_storage.arn}"
    } 
    
  ]
  EOF
}

# Kinesis Data Stream 
# We will keep the data for 24 hours, which is included in the base price.

resource "aws_kinesis_stream" "sensors" {
  name = "${local.project_name}"
  shard_count = 1
  retention_period = 24
}





# resource "aws_sns_topic" "mytopic" {
#   name = "mytopic"
# }

# resource "aws_sns_topic" "myerrortopic" {
#   name = "myerrortopic"
# }

# resource "aws_iam_role" "role" {
#   name = "myrole"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "iot.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "iam_policy_for_lambda" {
#   name = "mypolicy"
#   role = aws_iam_role.role.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#         "Effect": "Allow",
#         "Action": [
#             "sns:Publish"
#         ],
#         "Resource": "${aws_sns_topic.mytopic.arn}"
#     }
#   ]
# }
# EOF
# }



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

