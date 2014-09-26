Directory Backup
===================

Just upload directory and files to Amazon S3

## Setup

* create s3 bucket for backup
  * (See also: [Amazon S3 Lifecycle Management for Versioned Objects](https://aws.amazon.com/blogs/aws/amazon-s3-lifecycle-management-update/))

* write your own config in `config.yml`:

```YAML
aws_s3:
  access_key_id: 'YOUR_ACCESS_KEY_ID'
  secret_access_key: 'YOUR_SECRET_KEY_ID'
  bucket_name: 'my-bucket-for-backup'

backup_directories:
  include:
    - "~/"
  exclude:
    - 'tmp'
  file_size_limit: '50MB'

```

and run `ruby s3_backup.rb`
