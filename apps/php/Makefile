
.PHONY: docker-build
docker-build:
	docker build -t php-app .

.PHONY: docker-run
docker-run:
	 docker run --name=php-app -p 80:80 php-app:latest

.PHONY: docker-rund
docker-rund:
	docker run --name=php-app -d -p 80:80 php-app:latest

.PHONY: docker-stop
docker-stop:
	docker stop php-app

.PHONY: docker-login
docker-login: # aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 111729354111.dkr.ecr.eu-north-1.amazonaws.com
	docker login 111729354111.dkr.ecr.eu-north-1.amazonaws.com

.PHONY: docker-push
docker-push:
	docker tag php-app 111729354111.dkr.ecr.eu-north-1.amazonaws.com/php-app:latest
	docker push 111729354111.dkr.ecr.eu-north-1.amazonaws.com/php-app:latest

.PHONY: helm-package
helm-package:
	helm package helm

.PHONY: helm-push
helm-push:
	helm package helm
	helm push php-app-chart-0.1.1.tgz oci://111729354111.dkr.ecr.eu-north-1.amazonaws.com/

.PHONY: describe-images
describe-images:
	aws ecr describe-images --repository-name php-app-chart --region eu-north-1
	aws ecr describe-images --repository-name php-app --region eu-north-1
