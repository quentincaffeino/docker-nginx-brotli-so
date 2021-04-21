
###> quiet ###
## Override this value with a blank string to make make print each command it runs
QUIET ?= @
###< quiet ###

###> env ###
## Environment name (leave blank for dev, use prod for production and etc...) [default: ]
ENV ?=

## Path to the dotenv files [default:.]
ENV_PATH ?= .

## List of variables to omit while exporting
SKIP_EXPORT_FOR ?= 

include $(ENV_PATH)/.env
-include $(ENV_PATH)/.env.local
VARS := $(filter-out $(SKIP_EXPORT_FOR),$(shell grep -shoP "^[^\#=]+(?==)(?!.*;)" $(ENV_PATH)/.env $(ENV_PATH)/.env.local))
$(foreach v, $(VARS), $(eval $(shell echo export $(v) = "$($(v))")))

ifneq ("$(ENV)", "")
include $(ENV_PATH)/.env.$(ENV)
-include $(ENV_PATH)/.env.$(ENV).local
VARS := $(filter-out $(SKIP_EXPORT_FOR),$(shell grep -shoP "^[^\#=]+(?==)(?!.*;)" $(ENV_PATH)/.env.$(ENV) $(ENV_PATH)/.env.$(ENV).local))
$(foreach v, $(VARS), $(eval $(shell echo export $(v) = "$($(v))")))
endif
###< env ###

###> make-help ###
# @see https://github.com/ianstormtaylor/makefile-help
## Show this help prompt.
help:
	$(QUIET) echo
	$(QUIET) echo '  Usage:'
	$(QUIET) echo ''
	$(QUIET) echo '    make <target> [flags...]'
	$(QUIET) echo ''
	$(QUIET) echo '  Targets:'
	$(QUIET) echo ''
	$(QUIET) awk '/^##/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+:/{ print "   ", $$1, comment }' $(MAKEFILE_LIST) | column -t -s ':' | sort
	$(QUIET) echo ''
	$(QUIET) echo '  Flags:'
	$(QUIET) echo ''
	$(QUIET) awk '/^##/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?\?=/{ print "   ", $$1, $$2, comment }' $(MAKEFILE_LIST) | column -t -s '?=' | sort
	$(QUIET) echo ''
###< make-help ###
