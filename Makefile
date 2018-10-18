BUILD_TAG := $(or $(BUILD_TAG), $(shell date +%s))
KUBERNETES_VERSION ?= 1.10.3

DATE ?= $(shell date +%Y-%m-%d)

# Defaults to Amazon Linux 2 LTS AMI
# * use the us-west-2 minimal hvm image
# https://aws.amazon.com/amazon-linux-2/release-notes/
SOURCE_AMI_ID ?= $(shell aws ec2 describe-images \
	--output text \
	--filters \
		Name=owner-id,Values=137112412989 \
		Name=virtualization-type,Values=hvm \
		Name=root-device-type,Values=ebs \
		Name=name,Values=amzn2-ami-minimal-hvm-* \
		Name=architecture,Values=x86_64 \
		Name=state,Values=available \
	--query 'max_by(Images[], &CreationDate).ImageId')

AWS_DEFAULT_REGION = us-west-2

.PHONY: all validate ami

all: ami

validate:
	packer validate eks-worker-al2.json

ami: validate
	packer build -color=false -var build_tag=$(BUILD_TAG) -var source_ami_id=$(SOURCE_AMI_ID) eks-worker-al2.json
