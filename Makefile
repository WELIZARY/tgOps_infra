# tgops_infra, единый интерфейс операций
# использование - make help

SHELL := bash
TF    := terraform
ENV   := terraform/envs/prod
BOOT  := terraform/bootstrap

.DEFAULT_GOAL := help

# init слоя с backend.hcl и tfvars
define tfinit
	@if ! ls $(1)/*.tf >/dev/null 2>&1; then echo "слой $(1) не реализован"; exit 1; fi
	@[ -f $(1)/backend.hcl ] || cp $(1)/backend.hcl.example $(1)/backend.hcl
	@[ -f $(1)/terraform.tfvars ] || cp $(1)/terraform.tfvars.example $(1)/terraform.tfvars
	$(TF) -chdir=$(1) init -backend-config=backend.hcl -upgrade
endef

.PHONY: help
help: ## список команд
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	 | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n",$$1,$$2}'

.PHONY: bootstrap
bootstrap: ## первичный настройка (bootstrap) один раз, локальный state
	@[ -f $(BOOT)/terraform.tfvars ] || cp $(BOOT)/terraform.tfvars.example $(BOOT)/terraform.tfvars
	$(TF) -chdir=$(BOOT) init
	$(TF) -chdir=$(BOOT) apply

.PHONY: platform-apply platform-plan platform-destroy
platform-plan: ## план слоя платформы
	$(call tfinit,$(ENV)/10-platform)
	$(TF) -chdir=$(ENV)/10-platform plan
platform-apply: ## поднять платформу (сеть, dns, iam)
	$(call tfinit,$(ENV)/10-platform)
	$(TF) -chdir=$(ENV)/10-platform apply
platform-destroy: ## снести платформу (в самом конце)
	$(TF) -chdir=$(ENV)/10-platform destroy

.PHONY: apps-apply apps-plan apps-destroy
apps-plan: ## план слоя приложений
	$(call tfinit,$(ENV)/30-apps)
	$(TF) -chdir=$(ENV)/30-apps plan
apps-apply: ## поднять приложения (бот, сайты, jenkins)
	$(call tfinit,$(ENV)/30-apps)
	$(TF) -chdir=$(ENV)/30-apps apply
apps-destroy: ## удалить приложения
	$(TF) -chdir=$(ENV)/30-apps destroy

.PHONY: demo-up demo-down
demo-up: ## поднять cloud sql ha, мониторинг, demo
	$(call tfinit,$(ENV)/20-data)
	$(TF) -chdir=$(ENV)/20-data apply
	$(call tfinit,$(ENV)/40-observability)
	$(TF) -chdir=$(ENV)/40-observability apply
	@echo "demo поднят, не забудь make demo-down после сессии (бюджет)"
demo-down: ## удалить 
	-$(TF) -chdir=$(ENV)/40-observability destroy
	-$(TF) -chdir=$(ENV)/20-data destroy
	@echo "дорогие слои погашены"

.PHONY: status fmt
status: ## показать какие слои подняты
	@bash scripts/lifecycle/status.sh
fmt: ## terraform fmt по всему дереву
	$(TF) fmt -recursive terraform
