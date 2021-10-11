# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

# basic pre-checks
EXECUTABLES = aws terraform
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),,$(error "Command '$(exec)' not found in PATH.")))

$(call check_defined, \
            AWS_PROFILE \
            AWS_DEFAULT_REGION \
						TF_VAR_tfstate_bucket, \
						all variables must be set beforehand)

### variables
tfvars         = "../${AWS_DEFAULT_REGION}.tfvars"
path           = stages
stages         = infra manage

backend-config = -backend-config="bucket=${TF_VAR_tfstate_bucket}" \
                 -backend-config="region=${AWS_DEFAULT_REGION}" \
				         -backend-config="profile=${AWS_PROFILE}"

auto-approve   = "--auto-approve"
var-file       = "-var-file=${tfvars}"

reverse        = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

remove-state	 = $(foreach stage,$(stages), rm -rf $(path)/$(stage)/.terraform/terraform.tfstate;)

command        = $(foreach stage,$(stages), terraform -chdir=$(path)/$(stage) $(args);)

.PHONY: all rmstate init apply output purge destroy clean
all: init apply

rmstate:
	$(remove-state)

init: rmstate
	$(eval args = $@ $(backend-config))
	$(command)

plan:
	$(eval args = $@ $(var-file))
	$(command)

apply:
	$(eval args = $@ $(auto-approve) $(var-file))
	$(command)

output:
	$(eval args = $@)
	$(command)

purge: clean rmstate

# an alias due to force of habit
destroy: clean

clean:
	$(eval stages = $(call reverse,$(stages)))
	$(eval args = destroy $(auto-approve) $(var-file))
	$(command)
