resource "aws_s3_bucket" "blog" {
  bucket = "mrgossett-blog"
  acl    = "private"
  region = "us-east-1"

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags {
    Project = "blog"
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.blog.arn}/html/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.blog.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.blog.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.blog.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.blog.bucket}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}
