# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY:	build push deploy-config deploy undeploy

IMAGE = fluentd-elasticsearch
TAG = 1.20-r4
REPOSITORY = omoser
#DAEMONSET_MANIFEST = fluentd-es-ds.yaml
DAEMONSET_MANIFEST = fluentd-es-fabric8-ds.yaml
IMAGE_REF = $(REPOSITORY)/$(IMAGE):$(TAG)
#IMAGE_REF = fabric8/fluentd-kubernetes:v1.20

LOGGING_HOST = vlmcaap001.at.inside

build:	
	docker build -t $(IMAGE):$(TAG) .
	docker tag $(IMAGE):$(TAG) $(IMAGE_REF)

push:	
	docker push $(IMAGE_REF)

deploy-config:
	ansible-playbook fluentd.yml -i inventory.lxadaot -e image_ref=$(IMAGE_REF) -e logging_host=$(LOGGING_HOST)

deploy:
	@sed 's|@@IMAGE_REF@@|$(IMAGE_REF)|g' $(DAEMONSET_MANIFEST) | sed 's|@@LOGGING_HOST@@|$(LOGGING_HOST)|g' | kubectl apply -f -

undeploy:
	@sed 's|@@IMAGE_REF@@|$(IMAGE_REF)|g' $(DAEMONSET_MANIFEST) | sed 's|@@LOGGING_HOST@@|$(LOGGING_HOST)|g' | kubectl delete -f -

list-pods:
	kubectl get pods -n kube-system -l k8s-app=fluentd-es
