.PHONY: vet
vet:
	go vet ./...

.PHONY: fmt
fmt:
	go fmt ./...


.PHONY: gofumpt
gofumpt: gofumpt
	go install mvdan.cc/gofumpt@latest
	gofumpt -l -w .

.PHONY: goimports
goimports: goimports
	go install golang.org/x/tools/cmd/goimports@latest
	goimports -l -w .

.PHONY: lint
lint: golangci-lint ## Run the golang-ci linter
	$(GOLANGCI_LINT) run --allow-parallel-runners

.PHONY: test
test: fmt vet lint ## Run tests (skips integration tests)
	go test -v -race $$(go list ./... | grep -v 'integrationtest' | grep -v 'exper') -coverprofile cover.out


.PHONY: docker-build
docker-build:
	docker build -t golang-app .

.PHONY: docker-run
docker-run:
	 docker run --name=golang-app -p 80:80 golang-app:latest

.PHONY: docker-rund
docker-rund:
	docker run --name=golang-app -d -p 80:80 golang-app:latest

.PHONY: docker-stop
docker-stop:
	docker stop golang-app

.PHONY: docker-login
docker-login: # aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 111729354111.dkr.ecr.eu-north-1.amazonaws.com
	docker login 111729354111.dkr.ecr.eu-north-1.amazonaws.com

.PHONY: docker-push
docker-push:
	docker tag golang-app 111729354111.dkr.ecr.eu-north-1.amazonaws.com/golang-app:latest
	docker push 111729354111.dkr.ecr.eu-north-1.amazonaws.com/golang-app:latest

.PHONY: helm-package
helm-package:
	helm package helm

.PHONY: helm-push
helm-push:
	helm package helm
	helm push golang-app-chart-0.1.1.tgz oci://111729354111.dkr.ecr.eu-north-1.amazonaws.com/

.PHONY: describe-images
describe-images:
	aws ecr describe-images --repository-name golang-app-chart --region eu-north-1
	aws ecr describe-images --repository-name golang-app --region eu-north-1
