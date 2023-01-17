.PHONY: help backup cleanup initrestore restore start stop

SHELL := /bin/bash
K8S_VERSION := 1.21.7

BACKEND_CONTAINER := fyl_backend
DATABASE_CONTAINER := fyl_database
FRONTEND_CONTAINER := fyl_frontend

MK_STATUS = $(shell minikube status 1> /dev/null; echo $$?)
MK_CREATE = $(shell minikube start \
	--kubernetes-version=$(K8S_VERSION) 1> /dev/null)
MK_DELETE = $(shell minikube delete 1> /dev/null)
MK_ADDON_INGRESS =$(shell minikube addons enable ingress > /dev/null)

DOCKER_CREATE_DUMP = $(shell docker exec -it \
	$(DATABASE_CONTAINER) sh -c 'mysqldump \
	-uroot -p"$$MARIADB_ROOT_PASSWORD" application \
	> /root/dump.sql')
DOCKER_DOWNLOAD_DUMP = $(shell docker cp \
	$(DATABASE_CONTAINER):/root/dump.sql .)
DOCKER_UPLOAD_DUMP = $(shell docker cp dump.sql \
	$(DATABASE_CONTAINER):/root/dump.sql)
DOCKER_RESTORE_DUMP = $(shell docker exec -it \
	$(DATABASE_CONTAINER) sh -c 'mysqldump \
	-uroot -p"$$MARIADB_ROOT_PASSWORD" application \
	< /root/dump.sql' 1>/dev/null)

help:
	@echo "Usage: make COMMAND [VARIABLE=value ...]"
	@echo ""
	@echo "Commands"
	@echo "  backup                Create a database backup"
	@echo "  cleanup               Cleanup the development environment"
	@echo "  init                  Setup the development environment"
	@echo "  restore               Restore the database from a backup file"
# @echo "  start               ?"
# @echo "  stop                ?"
	@echo ""
	@echo "Variables"
	@echo "  BACKEND_CONTAINER     Name of the backend container (default: $(BACKEND_CONTAINER))"
	@echo "  DATABASE_CONTAINER    Name of the database container (default: $(DATABASE_CONTAINER))"
	@echo "  FRONTEND_CONTAINER    Name of the frontend container (default: $(FRONTEND_CONTAINER))"

backup:
	$(info Creating database backup.)
	@echo $(DOCKER_CREATE_DUMP)
	@echo $(DOCKER_DOWNLOAD_DUMP)
	$(info Database backup finished.)

cleanup:
ifeq ($(MK_STATUS), 0)
	$(info Deleting minikube cluster.)
	@echo $(MK_DELETE)
	$(info Minikube cluster deleted.)
else
	@echo "No minikube cluster found."
endif

init:
ifneq ($(MK_STATUS), 0)
	$(info No minikube cluster found. Creating one now. \
		This will take a few minutes.)
	@echo $(MK_CREATE)
	$(info Minikube cluster created.)
	$(info Adding ingress addon.)
	@echo $(MK_ADDON_INGRESS)
	$(info Minikube cluster is now ready.)
else
	@echo "Minikube cluster is already running."
endif

restore:
	$(info Restoring database backup.)
	@echo $(DOCKER_UPLOAD_DUMP)
	@echo $(DOCKER_RESTORE_DUMP)
	$(info Database backup restored.)
