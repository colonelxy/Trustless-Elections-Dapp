resource "aws_iam_role" "onboardingFirehorseRole" {
    name = "onboardingFirehorseRole"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "firehorse.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
  
}


resource "aws_iam_policy" "onboardingFirehoseRolePolicy" {
  name        = "onboardingFirehoseRolePolicy"
  path        = "/"
  description = "Onboarding firehorse role policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject*","s3:GetBucket*", "s3:List*", "s3:DeleteObject*", "s3:PutObject*", "s3:Abort*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "onboardingGlueRole" {
    name = "onboardingGlueRole"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
  
}

resource "aws_iam_policy" "onboardingGlueRolePolicy" {
  name        = "onboardingGlueRolePolicy"
  path        = "/"
  description = "Onboarding glue role policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams",
        ]
        Effect   = "Allow"
        Resource = "*"

        Action = [
          "s3:GetObject*","s3:GetBucket*", "s3:List*", "s3:DeleteObject*", "s3:PutObject*", "s3:Abort*",
        ]
        Effect   = "Allow"
        Resource = "*"

        Action = [
          "s3:GetObject*","s3:GetBucket*", "s3:List*", "s3:DeleteObject*", "s3:PutObject*", "s3:Abort*",
        ]
        Effect   = "Allow"
        Resource = "onboardingBucket"

        Action = [
          "s3:GetObject*","s3:GetBucket*", "s3:List*", "s3:DeleteObject*", "s3:PutObject*", "s3:Abort*",
        ]
        Effect   = "Allow"
        Resource = "onboardingBucketRefined"

        Action = [
          "s3:GetObject*","s3:GetBucket*", "s3:List*", "s3:DeleteObject*", "s3:PutObject*", "s3:Abort*",
        ]
        Effect   = "Allow"
        Resource = "onboardingBucketTemp"
      },
    ]
  })
}



resource "aws_glue_catalog_database" "onboardingGlueDatabase" {
  name = "onboardingGlueDatabase"

  create_table_default_permission {
    permissions = ["SELECT"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
    
}
}

resource "aws_s3_bucket" "onboardingBucket" {
  bucket = "onboardingBucket"
  acl    = "private"

  tags = {
    Name        = "iot-onboarding"
    Environment = "Dev"
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "onboardingBucketTemp" {
  bucket = "onboardingBucketTemp"
  acl    = "private"

  tags = {
    Name        = "iot-onboarding"
    Environment = "Dev"
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "onboardingBucketRefined" {
  bucket = "onboardingBucketRefined"
  acl    = "private"

  tags = {
    Name        = "iot-onboarding"
    Environment = "Dev"
  }

  versioning {
    enabled = true
  }
}


resource "aws_kinesis_firehose_delivery_stream" "onboardingSensorsDeliveryStream" {
  name        = "onboardingSensorsDeliveryStream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.onboardingFirehorseRole.arn
    bucket_arn = aws_s3_bucket.onboardingBucket.arn
  }
}

resource "aws_glue_crawler" "onboardingSensorDataCrawler" {
  database_name = aws_glue_catalog_database.onboardingGlueDatabase.name
  name          = "onboardingSensorDataCrawler"
#   role          = aws_iam_role.example.arn

  s3_target {
    path = "s3://${aws_s3_bucket.onboardingBucket.bucket}"
  }
}

resource "aws_glue_crawler" "onboardingSensorDataCrawlerRefined" {
  database_name = aws_glue_catalog_database.onboardingGlueDatabase.name
  name          = "onboardingSensorDataCrawler"
  role          = aws_iam_role.onboardingGlueRole.arn

  s3_target {
    path = "s3://${aws_s3_bucket.onboardingBucketRefined.bucket}"
  }
}

resource "aws_glue_job" "onboardingSensorFlatteningJob" {
  name     = "onboardingSensorFlatteningJob"
  role_arn = aws_iam_role.onboardingGlueRole.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.onboardingBucket.bucket}/iot-onboarding-quickstart-artifacts/dev/etl/iotOnboardingSensorFlatteningJob.py"
  }

  default_arguments = {
    # ... potentially other arguments ...
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.onboardingSensorFlatteningJob.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
  }

  execution_property {
    
    max_concurrent_runs = 1
  }

  max_retries = 0
  timeout = 60
  glue_version = "2.0"
#   role_arn
}

resource "aws_cloudwatch_log_group" "onboardingSensorFlatteningJob" {
  name              = "onboardingSensorFlatteningJob"
  retention_in_days = 14
}

resource "aws_glue_job" "onboardingSensorFlatteningJob" {
  # ... other configuration ...

  
}

resource "aws_glue_trigger" "onboardingSensorWorkflowTrigger" {
  name = "onboardingSensorWorkflowTrigger"
  type = "SCHEDULED"

  actions {
    crawlecrawler_name =  aws_glue_job.onboardingSensorDataCrawler.name
  }

  tags = {
    Name = iot-onboarding
  }

  schedule = "cron(0 * ? * * *)"
  start_on_creation = true
  
}

resource "aws_glue_trigger" "onboardingSensorFlatteningJobTrigger" {
  name = "onboardingSensorFlatteningJobTrigger"
  type = "SCHEDULED"

  actions {
    crawlecrawler_name =  aws_glue_job.onboardingSensorFlatteningJob.name
  }

  tags = {
    Name = iot-onboarding
  }

  schedule = "cron(5 * ? * * *)"
  start_on_creation = true
}

resource "aws_glue_trigger" "onboardingSensorRefinedTrigger" {
  name = "onboardingSensorRefinedTrigger"
  type = "CONDITIONAL"

  actions {
    crawlecrawler_name =  aws_glue_job.onboardingSensorDataCrawler.name
  }

  tags = {
    Name = iot-onboarding
  }

  schedule = "cron(5 * ? * * *)"
  start_on_creation = true
  predicate {
    JobName = onboardingSensorFlatteningJob
    LogicalOperator = EQUALS
    State = SUCCEED
  }
  
}

resource "aws_dynamodb_table" "onboardingSensorTable1" {
  name = onboardingSensorTable1
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = timestamp
    type = RANGE
  }
  attribute {
    name = deviceId
    type = HASH
  }

  
}




  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  attribute {
    name = "TopScore"
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  global_secondary_index {
    name               = "GameTitleIndex"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}