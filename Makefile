
# Syntax highlighting. MacOS ships with an old version of Bash that doesn't
# support the \e escape so we need to use this other escape sequence.
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

docker:  ## Build the Docker image
	@echo "\n~~~ $(BOLD)$(CYAN)Building Docker image$(NORMAL) ~~~"
	docker build --no-cache -t fargate-app-repo -f dockerfiles/Dockerfile context

clean:
	@echo "\n~~~ $(BOLD)$(CYAN)Cleaning up$(NORMAL) ~~~"


.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

