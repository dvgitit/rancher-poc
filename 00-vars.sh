######################## HOSTS LIST ###########################
## Hosts to remote control in $HOST_LIST_FILE (one target per line)
HOST_LIST_FILE=./hosts.list

######################## IF AIRGAP SETUP #########################
## Deploiement airgap: tapez 1 sinon 0
AIRGAP_DEPLOY="1"
AIRGAP_REGISTRY_URL="http://mon_registry:5000"
# Optional user/password
AIRGAP_REGISTRY_USER="toto"
AIRGAP_REGISTRY_PASSWD=""

######################## IF PROXY SETUP ##########################
## Proxy settings (leave empty aka "" if you don't want proxy setting to trigger)
PROXY_DEPLOY="1"
_HTTP_PROXY="squid:3128"
_HTTPS_PROXY="squid:3128"
_NO_PROXY="127.0.0.1,172.16.2.27,172.16.2.28,172.16.2.29,172.16.2.30,cattle-system.svc"
PROXY_CA="proxyCA.pem"

######################## DOCKER SETUP ############################
## Docker version to use (to be deprecated) 
DOCKER_VERSION="19.03"  # options [19.03|20.10]
## Docker user to be created on target hosts
DOCKER_USER="rkedeploy"
## Docker group to be joined by Docker user
DOCKER_GROUP="docker"	# 'dockerroot' for docker provided by RHEL

######################## REPOSITORIES ############################
## NON-FONCTIONNEL - Repositories (REPO_MODE: 1=SUSE Manager / 2=RMT Server / 3="Do nothing, I'm good")
#REPO_MODE=1
REPO_SERVER="suma01.zypp.lo"

######################## CHECK STORAGE NETWORK ###################
## Existing storage network host for basic check
STORAGE_TARGET="192.168.1.11"

######################## SELECT VERSIONS #########################
## K8S cluster, RKE and Helm versions to deploy
KUBERNETES_VERSION="v1.19.3-rancher1-1"
RKE_VERSION="v1.2.6"
HELM_VERSION="3.5.3"

######################## FQDNs & DOMAINs #########################
## K8S Masters load balanced DNS name
LB_MASTERS="api.apps.zypp.lo"
## Apps private DNS domain
dom="apps.zypp.lo"
## Apps public DNS domain (optional)
ext_dom="apps.office.zypp.fr"
