BUILD_TAG := $(or $(BUILD_TAG), $(shell date +%s))
KUBERNETES_VERSION ?= 1.10.3

DATE ?= $(shell date +%Y-%m-%d)
AWS_DEFAULT_REGION = us-east-1

SOURCE_AMI_ID ?= $(shell aws ec2 describe-images \
	--output text \
	--filters \
		Name=owner-id,Values=099720109477 \
		Name=virtualization-type,Values=hvm \
		Name=root-device-type,Values=ebs \
		Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-* \
		Name=architecture,Values=x86_64 \
		Name=state,Values=available \
	--query 'max_by(Images[], &CreationDate).ImageId')

.PHONY: all validate ami

all: ami

validate:
	packer validate eks-worker-bionic.json

ami: validate
	packer build -color=false -var build_tag=$(BUILD_TAG) -var source_ami_id=$(SOURCE_AMI_ID) eks-worker-bionic.json
