#start localstack

```
set AWS_ACCESS_KEY_ID=poo && set AWS_SECRET_ACCESS_KEY=Poo
docker run -it --rm -p 4566:4566 -p 4510-4559:4510-4559 -d -v /var/run/docker.sock:/var/run/docker.sock -v %cd%\volume:/var/lib/localstack -e SKIP_SSL_CERT_DOWNLOAD=1 --name=robin localstack/localstack:3.2.0
```

# awslocal

this is made available in the localstack python module:

```
python -v venv localstack
localstack\Scripts\activate
```

get the dependancies:

```
# first time only:
pip install localstack awscli-local terraform-local --trusted-host=pypi.org --trusted-host=files.pythonhosted.org
```

# create role to enable lambda execute

```
awslocal iam create-role --role-name LambdaBasicExecution --assume-role-policy-document file://policies/trust-policy.json
awslocal iam attach-role-policy --role-name LambdaBasicExecution --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

# create a bucket, create policy to allow read/write to bucket

```
awslocal s3api create-bucket --bucket robinsbucket
awslocal iam create-policy --policy-name robinbucketpolicy --policy-document file://policies/robinbucketpolicy.json
awslocal iam attach-role-policy --role-name LambdaBasicExecution --policy-arn arn:aws:iam::000000000000:policy/robinbucketpolicy
```

# quick check

```
awslocal iam list-attached-role-policies --role-name LambdaBasicExecution
```

# package python

this is used like this to get the correct format of the directory structure, trust me.

```
python -c "import shutil;shutil.make_archive('function', 'zip', base_dir='.', root_dir='lambda')"
```

# create function / update

(have to use the role-arn that it put out from creating it)

```
awslocal lambda create-function --function-name robinslambda --zip-file fileb://function.zip --handler robin.lambda_handler --runtime python3.8 --role arn:aws:iam::000000000000:role/LambdaBasicExecution
# awslocal lambda update-function-configuration --function-name robinslambda --handler robin.lambda_handler
# awslocal lambda update-function-code --function-name robinslambda --zip-file fileb://function.zip
```

# invoke

```
set AWS_DEFAULT_REGION=eu-west-2
awslocal lambda invoke --function-name robinslambda outputfile.txt
awslocal s3 cp s3://robinsbucket/hello.txt -
```

# localstack cloudwatch equivalent


```
docker container ls --all --no-trunc --last 2 # to show the last 2 containers it spun up, one is going to be from the ecr image that's running the lambda code
docker logs <lambda container name>
docker logs robin-lambda-robinslambda-c88dedc75aefeadfa45074eff091767b
```

# Terraform

Terraform code exists in ```main.tf``` which constructs the same, to use,  the localstack python install provides tflocal:

```
set AWS_ACCESS_KEY_ID=poo && set AWS_SECRET_ACCESS_KEY=Poo
tflocal init #once
tflocal apply
```