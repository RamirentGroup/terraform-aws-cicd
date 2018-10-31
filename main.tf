data "aws_caller_identity" "default" {}

data "aws_region" "default" {
  current = true
}

# Define composite variables for resources
module "label" {
  source     = "git::https://github.com/RamirentGroup/terraform-generic-label.git?ref=1.0_GA"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

resource "aws_s3_bucket" "default" {
  count  = "${var.enabled == "true" ? 1 : 0}"
  bucket = "${module.label.id}"
  acl    = "private"
  tags   = "${module.label.tags}"
}

resource "aws_iam_role" "default" {
  count              = "${var.enabled == "true" ? 1 : 0}"
  name               = "${module.label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  count      = "${var.enabled == "true" ? 1 : 0}"
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.default.arn}"
}

resource "aws_iam_policy" "default" {
  count  = "${var.enabled == "true" ? 1 : 0}"
  name   = "${module.label.id}"
  policy = "${data.aws_iam_policy_document.default.json}"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "iam:PassRole",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  count      = "${var.enabled == "true" ? 1 : 0}"    
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_iam_policy" "s3" {
  count  = "${var.enabled == "true" ? 1 : 0}"
  name   = "${module.label.id}-s3"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

data "aws_iam_policy_document" "s3" {
  count  = "${var.enabled == "true" ? 1 : 0}"
  statement {
    sid = ""

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.default.arn}",
      "${aws_s3_bucket.default.arn}/*",
      "arn:aws:s3:::elasticbeanstalk*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  count      = "${var.enabled == "true" ? 1 : 0}"
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.codebuild.arn}"
}

resource "aws_iam_policy" "codebuild" {
  count  = "${var.enabled == "true" ? 1 : 0}"
  name   = "${module.label.id}-codebuild"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = ""

    actions = [
      "codebuild:*",
    ]

    resources = ["${module.build.project_id}"]
    effect    = "Allow"
  }
}

module "build" {
  source             = "git::https://github.com/RamirentGroup/terraform-aws-codebuild.git?ref=1.9_GA"
  enabled            = "${var.enabled}"
  namespace          = "${var.namespace}"
  name               = "${var.name}"
  stage              = "${var.stage}"
  build_image        = "${var.build_image}"
  build_compute_type = "${var.build_compute_type}"
  cache_enabled      = "${var.build_cache_enable}"
  buildspec          = "${var.buildspec}"
  delimiter          = "${var.delimiter}"
  attributes         = "${concat(var.attributes, list("build"))}"
  tags               = "${var.tags}"
  privileged_mode    = "${var.privileged_mode}"
  aws_region         = "${signum(length(var.aws_region)) == 1 ? var.aws_region : data.aws_region.default.name}"
  aws_account_id     = "${signum(length(var.aws_account_id)) == 1 ? var.aws_account_id : data.aws_caller_identity.default.account_id}"
  image_repo_name    = "${var.image_repo_name}"
  image_tag          = "${var.image_tag}"
  github_token       = "${var.github_oauth_token}"
  environment_variables = "${var.codebuild_environment_variables}"
  codebuild_var1     = "${var.codebuild_var1}"
  codebuild_var1_val = "${var.codebuild_var1_val}"
  codebuild_var2     = "${var.codebuild_var2}"
  codebuild_var2_val = "${var.codebuild_var2_val}"
  codebuild_var3     = "${var.codebuild_var3}"
  codebuild_var3_val = "${var.codebuild_var3_val}"
  codebuild_var4     = "${var.codebuild_var4}"
  codebuild_var4_val = "${var.codebuild_var4_val}"
  codebuild_var5     = "${var.codebuild_var5}"
  codebuild_var5_val = "${var.codebuild_var5_val}"
  codebuild_var6     = "${var.codebuild_var6}"
  codebuild_var6_val = "${var.codebuild_var6_val}"
  codebuild_var7     = "${var.codebuild_var7}"
  codebuild_var7_val = "${var.codebuild_var7_val}"
  codebuild_var8     = "${var.codebuild_var8}"
  codebuild_var8_val = "${var.codebuild_var8_val}"
  codebuild_var9     = "${var.codebuild_var9}"
  codebuild_var9_val = "${var.codebuild_var9_val}"
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  count      = "${var.enabled == "true" ? 1 : 0}"
  role       = "${module.build.role_arn}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

# Only one of the `aws_codepipeline` resources below will be created:

# "source_build_deploy_ebs" will be created if `var.enabled` is set to `true` and the Elastic Beanstalk application name and environment name are specified

# This is used in two use-cases:

# 1. GitHub -> S3 -> Elastic Beanstalk (running application stack like Node, Go, Java, IIS, Python)

# 2. GitHub -> ECR (Docker image) -> Elastic Beanstalk (running Docker stack)

# "source_build" will be created if `var.enabled` is set to `true` and the Elastic Beanstalk application name or environment name are not specified

# This is used in this use-case:

# 1. GitHub -> ECR (Docker image)

resource "aws_codepipeline" "source_build_deploy_ebs" {
  # Elastic Beanstalk application name and environment name are specified
  count    = "${var.enabled && !var.approve && signum(length(var.ebs_app)) == 1 && signum(length(var.ebs_env)) == 1 ? 1 : 0}"
  name     = "${module.label.id}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${module.build.project_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["package"]
      version         = "1"

      configuration {
        ApplicationName = "${var.ebs_app}"
        EnvironmentName = "${var.ebs_env}"
      }
    }
  }
}

resource "aws_codepipeline" "source_build_deploy_ebs_approve" {
  # Elastic Beanstalk application name and environment name are specified
  count    = "${var.enabled && var.approve && signum(length(var.ebs_app)) == 1 && signum(length(var.ebs_env)) == 1 ? 1 : 0}"
  name     = "${module.label.id}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration {
        CustomData = "${var.approve_comment}"
        ExternalEntityLink = "${var.approve_url}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${module.build.project_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["package"]
      version         = "1"

      configuration {
        ApplicationName = "${var.ebs_app}"
        EnvironmentName = "${var.ebs_env}"
      }
    }
  }
}

resource "aws_codepipeline" "source_build_deploy_ecs" {
  # ECS cluster and service are specified and NO approve
  count    = "${var.enabled && !var.approve && signum(length(var.ecs_service)) == 1 && signum(length(var.ecs_cluster)) == 1 ? 1 : 0}"
  name     = "${module.label.id}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${module.build.project_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["package"]
      version         = "1"

      configuration {
        ClusterName   = "${var.ecs_cluster}"
        ServiceName   = "${var.ecs_service}"
        FileName      = "${var.ecs_images_file}"
      }
    }
  }
}

resource "aws_codepipeline" "source_build_deploy_ecs_approve" {
  # ECS cluster and service are specified and NO approve
  count    = "${var.enabled && var.approve && signum(length(var.ecs_service)) == 1 && signum(length(var.ecs_cluster)) == 1 ? 1 : 0}"
  name     = "${module.label.id}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  # Approve must be BEFORE build as Build pushes new image to repo
  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration {
        CustomData = "${var.approve_comment}"
        ExternalEntityLink = "${var.approve_url}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${module.build.project_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["package"]
      version         = "1"

      configuration {
        ClusterName   = "${var.ecs_cluster}"
        ServiceName   = "${var.ecs_service}"
        FileName      = "${var.ecs_images_file}"
      }
    }
  }
}

resource "aws_codepipeline" "source_build_approve" {
  # No EBS/ECS + approve
  count    = "${var.enabled && var.approve && (signum(length(var.ebs_app) + length(var.ebs_env) + length(var.ecs_cluster) + length(var.ecs_service)) == 0) ? 1 : 0}"
  name     = "${module.label.id}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "Approve"
    
    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration {
        CustomData = "${var.approve_comment}"
        ExternalEntityLink = "${var.approve_url}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${module.build.project_name}"
      }
    }
  }
}


resource "aws_codepipeline" "source_build" {
  # No EBS/ECS + NO approve
  count    = "${var.enabled && !var.approve && (signum(length(var.ebs_app) + length(var.ebs_env) + length(var.ecs_cluster) + length(var.ecs_service)) == 0) ? 1 : 0}"
  name     = "${module.label.id}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${module.build.project_name}"
      }
    }
  }
}
  
