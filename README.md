# s3g

AWS S3 GET client

## Usage

Export environment variables.

```
$ export_AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
$ export_AWS_SECRET_ACCESS_KEY_ID=YOUR_AWS_SECRET_ACCESS_KEY_ID
$ export AWS_REGION=ap-northeast-1
```

Send a GET request.

```
$ ./s3g.rb --path '/path/to/bucket/and/object'
```
