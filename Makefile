AWS_REGION ?= us-east-1
BUILD_TAG := $(or $(BUILD_TAG), $(shell date +%s))
KUBERNETES_VERSION ?= 1.10.3

DATE ?= $(shell date +%Y-%m-%d)
AWS_DEFAULT_REGION = us-east-1

SOURCE_AMI_ID ?= $(shell aws ec2 describe-images \
	--region $(AWS_REGION) \
	--output text \
	--filters \
		Name=owner-id,Values=099720109477 \
		Name=virtualization-type,Values=hvm \
		Name=root-device-type,Values=ebs \
		Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-* \
		Name=architecture,Values=x86_64 \
		Name=state,Values=available \
	--query 'max_by(Images[], &CreationDate).ImageId')

.PHONY: all validate ami 1.12 1.11 1.10

all: 1.10

validate:
	packer validate eks-worker-bionic.json

1.10: validate
	packer build \
		-color=false \
		-var aws_region=$(AWS_REGION) \
		-var kubernetes_version=1.10 \
		-var binary_bucket_path=1.10.13/2019-03-27/bin/linux/amd64 \
		-var build_tag=$(BUILD_TAG) \
		-var encrypted=true \
		-var source_ami_id=$(SOURCE_AMI_ID) \
		eks-worker-bionic.json

1.11: validate
	packer build \
		-color=false \
		-var aws_region=$(AWS_REGION) \
		-var kubernetes_version=1.11 \
		-var binary_bucket_path=1.11.9/2019-03-27/bin/linux/amd64 \
		-var build_tag=$(BUILD_TAG) \
		-var encrypted=true \
		-var source_ami_id=$(SOURCE_AMI_ID) \
		eks-worker-bionic.json

1.12: validate
	packer build \
		-var aws_region=$(AWS_REGION) \
		-var kubernetes_version=1.12 \
		-var binary_bucket_path=1.12.7/2019-03-27/bin/linux/amd64 \
		-var build_tag=$(BUILD_TAG) \
		-var encrypted=true \
		-var source_ami_id=$(SOURCE_AMI_ID) \
		eks-worker-bionic.json
