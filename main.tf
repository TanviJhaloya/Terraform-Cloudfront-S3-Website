#create s3 bucket

resource "aws_s3_bucket" "b1" {
  bucket = var.bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

#upload object

  resource "aws_s3_bucket_object" "object" {
  bucket =  aws_s3_bucket.b1.id
  key    = "index.html"
  source = "path_to_file"
   acl    = "public-read"
   etag = filemd5("path_to_file")
}

locals {
  s3_origin_id = "myS3Origin"
}

#create cloudfront distribution

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.b1.bucket_regional_domain_name
    origin_id = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

 

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  

  tags = {
    Environment = "production"
  }
  

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
