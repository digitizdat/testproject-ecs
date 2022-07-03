# This code requires a few keys to be set in the environment
ifeq ($(AWS_DEFAULT_REGION),)
$(error "You must set the AWS_DEFAULT_REGION variable")
endif
ifeq ($(AWS_ACCESS_KEY_ID),)
$(error "You must set the AWS_ACCESS_KEY_ID variable")
endif
ifeq ($(AWS_SECRET_ACCESS_KEY),)
$(error "You must set the AWS_SECRET_ACCESS_KEY variable")
endif
ifeq ($(AWS_ACCOUNT_NUMBER),)
$(error "You must set the AWS_ACCOUNT_NUMBER variable")
endif


AWS_ECR_REPONAME=fargate-app-repo
AWS_ECR_HOSTNAME=$(AWS_ACCOUNT_NUMBER).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com

# Syntax highlighting. MacOS ships with an old version of Bash that doesn't
# support the \e escape so we need to use this other escape sequence.
#
#
ifeq ("$(strip $(shell uname))","Darwin")
ESC=\x1B
else
ESC=\e
endif

# These are mainly just used to create a headline for each target so it's a
# little easier to visually sort through the output.
BOLD=$(ESC)[1m
CYAN=$(ESC)[36m
NORMAL=$(ESC)[0m

all: lint docker ## Build everything
lint:  ## Run the linter(s)
depends:  ## Install dependencies
	pip install -r requirements.txt

ecrauth:  ## Login to the ECR repo
	aws ecr get-login-password --region $(AWS_DEFAULT_REGION) | docker login --username AWS --password-stdin $(AWS_ECR_HOSTNAME)

docker:  ## Create the Docker image
	@echo "\n~~~ $(BOLD)$(CYAN)Creating the Docker image$(NORMAL) ~~~"
	docker build -t $(AWS_ECR_REPONAME) -f dockerfiles/Dockerfile context
	docker tag $(AWS_ECR_REPONAME):latest $(AWS_ECR_HOSTNAME)/$(AWS_ECR_REPONAME):latest
	docker push $(AWS_ECR_HOSTNAME)/$(AWS_ECR_REPONAME):latest

clean:
	@echo "\n~~~ $(BOLD)$(CYAN)Cleaning up$(NORMAL) ~~~"


.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

