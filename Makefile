# Variables
NAMESPACE = artifacthub

# Install artifacthub 
install_artifacthub:
	oc new-project $(NAMESPACE)
	helm repo add artifact-hub https://artifacthub.github.io/helm-charts
	helm install hub artifact-hub/artifact-hub
	

# Fix security context in openshift
patch_security_context:
# create a privileged service account
	oc create sa privileged-sa -n $(NAMESPACE)
	oc adm policy add-scc-to-user privileged -z privileged-sa -n $(NAMESPACE)


# patch service acccount name
	oc patch statefulset -n $(NAMESPACE) hub-postgresql --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/serviceAccountName", "value": "privileged-sa"}]'
# edit security context inside containers as privileged	in postgres statefulset
	oc patch statefulset -n $(NAMESPACE) hub-postgresql --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/initContainers/0/securityContext/privileged", "value": true}]'
	oc patch statefulset -n $(NAMESPACE) hub-postgresql --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/securityContext/privileged", "value": true}]'


patch_environment_variables:
# add HOME environment variable in hub deployment
	oc patch deployment -n $(NAMESPACE) hub --type='json' -p='[{"op": "add", "path": "/spec/template/spec/initContainers/0/env/-", "value": {"name": "HOME", "value": "/home/hub"}}]'
	oc patch deployment -n $(NAMESPACE) hub --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env", "value": [{"name": "HOME", "value": "/home/hub"}]}]'
	
# add HOME environment variable in tracker cronjob
	oc patch cronjob -n $(NAMESPACE) tracker --type='json' -p='[{"op": "add", "path": "/spec/jobTemplate/spec/template/spec/initContainers/0/env/-", "value": {"name": "HOME", "value": "/home/tracker"}}]'
	oc patch cronjob -n $(NAMESPACE) tracker --type=json -p='[{"op": "add", "path": "/spec/jobTemplate/spec/template/spec/containers/0/env", "value": [{"name": "HOME", "value": "/home/tracker"}]}]'

# start tracker job
start_tracker:
	oc create job -n $(NAMESPACE) initial-tracker-job --from=cronjob/tracker

# expose artifacthub
expose_artifacthub:
	oc expose service -n $(NAMESPACE) hub --name=artifacthub 

wait_for_pods:
    # wait for a particular pod with a label to be running
	# oc wait pod --for=condition=Ready -l app.kubernetes.io/component=hub --namespace=$(NAMESPACE) --timeout=180s
	echo "Artifact hub is Ready" $(oc get route -n $(NAMESPACE) artifacthub -o jsonpath='{.spec.host}')


all: install_artifacthub patch_security_context patch_environment_variables start_tracker expose_artifacthub wait_for_pods
