#!/bin/bash

### Source des variables
. ./00-vars.sh

bold=$(tput bold)
normal=$(tput sgr0)
clear

#Creation de la table HOSTS a partir du fichier HOST_LIST_FILE

echo "Lecture de la liste des hotes dans $HOST_LIST_FILE"
mapfile -t HOSTS < $HOST_LIST_FILE
echo "Liste des hotes cibles:"
echo
printf '%s\n' "${HOSTS[@]}"
echo

#Selection du package manager à utiliser pour les futures commandes

while true; do
   read -p "${bold}Package manager type? (zypper/yum/apt) ${normal}" pkg_mgr_type
   case $pkg_mgr_type in
      [zypper]* )
            echo "$pkg_mgr_type selected."
            echo
            break;;
      [yum]* ) 
            echo "$pkg_mgr_type selected."
            echo
	    break;;
      [apt]* ) 
            echo "$pkg_mgr_type selected."
            echo
	    break;;
      * ) echo "Please answer: zypper or yum or apt.";;
    esac
done

# Fonction generique de question (yes / no)

question_yn() {
while true; do
   echo -e "${bold}---\n $1 ${normal}"
   echo -e "${bold}---\n Commande:\n ${normal}"
   declare -f $2
   echo
   read -p " ${bold}Executer ? (y/n) ${normal}" yn
   echo
   case $yn in
      [Yy]* )
        $2
        echo
        read -rsp $'Pressez une touche pour continuer...\n' -n1 key
      break;;
      [Nn]* ) echo "Etape annulee";break;;
      * ) echo "Please answer yes (y) or no (n).";;
    esac
done
}

## PRE-CHECK PACKAGE
DESC_CHECK_PACKAGE="Verification de la présence des paquets?${bold}"
COMMAND_CHECK_PACKAGE_RPM() {
for i in $@;do echo "Recherche de la presence du paquet: ${bold}$i${normal}"
if rpm -q $i
then
  echo "${bold}$i${normal} is present. OK!";echo
else
  echo "${bold}$i${normal} is not present. ERROR!"
  echo "rpm -q ${bold}$i${normal}: 'not installed'"
fi
done
}

## SSH KEYS CREATION
DESC_SSH_KEYS="Creation d'une paire de clefs SSH en local?${bold}"
COMMAND_SSH_KEYS() {
ssh-keygen
}

## SSH KEYS DEPLOY
DESC_SSH_DEPLOY="Deploiement de la clef publique vers les noeuds?${bold}"
COMMAND_SSH_DEPLOY() {
read -s -p "Veuillez entrer le mot de passe des clients : " PASSWD
for h in ${HOSTS[*]};
  do expect -c "set timeout 2; spawn ssh-copy-id -o StrictHostKeyChecking=no $h; expect 'assword:'; send "$PASSWD\\r"; interact"
done;
}

## SSH CONNECT TESTING
DESC_SSH_CONNECT_TEST="Test de connexion en masse?${bold}"
COMMAND_SSH_CONNECT_TEST() {
for h in ${HOSTS[*]}; do ssh $h "hostname -f" ; done;
}

## SET PROXY
DESC_SET_PROXY="Des variables PROXY sont definies dans le fichier ./00-vars.sh. Appliquer ces parametres ? \n _HTTP_PROXY=${_HTTP_PROXY} \n _HTTPS_PROXY=${_HTTPS_PROXY} \n _NO_PROXY=${_NO_PROXY}${bold}"
COMMAND_SET_PROXY() {
for h in ${HOSTS[*]}
  do 
scp -o StrictHostKeyChecking=no proxyCA.pem $h:/etc/pki/ca-trust/source/anchors/
ssh $h "cat  > /etc/profile.d/proxy.sh <<EOF
export http_proxy=http://${_HTTP_PROXY}
export https_proxy=http://${_HTTPS_PROXY}
export no_proxy=${_NO_PROXY}
EOF
hostname -f
if [[ $pkg_mgr_type == 'zypper' ]]
then 
update-ca-certificates
fi
if [[ $pkg_mgr_type == 'yum' ]]
then 
update-ca-trust
fi
echo 'Parametres Proxy ajoutes dans /etc/profile.d/proxy.sh'"
done
# ajout en local egalement
cat  > /etc/profile.d/proxy.sh <<EOF
export http_proxy=http://${_HTTP_PROXY}
export https_proxy=http://${_HTTPS_PROXY}
export no_proxy=${_NO_PROXY}
EOF
scp -o StrictHostKeyChecking=no proxyCA.pem /etc/pki/ca-trust/source/anchors/
if [[ $pkg_mgr_type == 'zypper' ]]
then 
update-ca-certificates
fi
if [[ $pkg_mgr_type == 'yum' ]]
then 
update-ca-trust
fi
echo "$(hostname -f) : Parametres Proxy ajoutes dans /etc/profile.d/proxy.sh"
}

## LISTE DES REPOSITORIES
DESC_REPOS="$pkg_mgr_type - Liste des repos sur les noeuds${bold}"
COMMAND_REPOS_ZYPPER() {
for h in ${HOSTS[*]}
  do ssh $h "echo && hostname -f && echo && zypper lr"; 
done
}
COMMAND_REPOS_YUM() {
for h in ${HOSTS[*]}
  do ssh $h "echo && hostname -f && echo && yum repolist all"; 
done
}

## ADDING REPOSITORIES
DESC_ADDREPOS="$pkg_mgr_type - Ajout des repos containers-modules sur les noeuds et en local?${bold}"
COMMAND_ADDREPOS_ZYPPER() {
for h in ${HOSTS[*]}
  do ssh $h "echo ; hostname -f ; echo ; zypper ref ; 
zypper ar -G http://$REPO_SERVER/ks/dist/child/sle-module-containers15-sp2-pool-x86_64/sles15sp2 containers_product ; 
zypper ar -G http://$REPO_SERVER/ks/dist/child/sle-module-containers15-sp2-updates-x86_64/sles15sp2 containers_updates" 
done
zypper ar -G http://$REPO_SERVER/ks/dist/child/sle-module-containers15-sp2-pool-x86_64/sles15sp2 containers_product
zypper ar -G http://$REPO_SERVER/ks/dist/child/sle-module-containers15-sp2-updates-x86_64/sles15sp2 containers_updates
}

COMMAND_ADDREPOS_YUM() {
for h in ${HOSTS[*]}
  do ssh $h "echo ; hostname -f ; echo
cat  > /etc/yum.repos.d/res7.repo <<EOF
[res7]
name=res7
baseurl=http://$REPO_SERVER/ks/dist/child/res7-x86_64/rhel76
enabled=1
gpgcheck=0
EOF
cat  > /etc/yum.repos.d/res7-iso.repo <<EOF
[res7-iso]
name=res7.6-ISO
baseurl=http://$REPO_SERVER/ks/dist/child/rhel76-iso/rhel76
enabled=1
gpgcheck=0
EOF
cat  > /etc/yum.repos.d/res7-suma.repo <<EOF
[res7-SUMA]
name=res7-SUMA_BOOTSTRAP
baseurl=http://$REPO_SERVER/ks/dist/child/res7-suse-manager-tools-x86_64/rhel76
enabled=1
gpgcheck=0
EOF"
done
}

## YUM SPECIFIC REPO FOR K8S TOOLS 
DESC_ADDREPOS_YUM_K8STOOLS="$pkg_mgr_type - Ajout du repo public pour les outils K8S (kubectl...)?${bold}"
COMMAND_ADDREPOS_YUM_K8STOOLS() {
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
echo -e "Repo for K8S Tools has been added."
}

## ALL NODES UPDATE 
DESC_NODES_UPDATE="$pkg_mgr_type - Mise à jour de tous les noeuds?${bold}"
COMMAND_NODES_UPDATE_ZYPPER() {
for h in ${HOSTS[*]}
  do ssh $h "echo ; hostname -f ; echo ; zypper ref ; zypper --non-interactive up"
done;
for h in ${HOSTS[*]}
  do ssh $h "echo ; zypper ps" 
done
}

COMMAND_NODES_UPDATE_YUM() {
for h in ${HOSTS[*]}
  do ssh $h "echo ; hostname -f ; echo ; yum -y update"
done;
}

## CHECK TIME
DESC_CHECK_TIME="Verification de la date & heure sur les noeuds?${bold}"
COMMAND_CHECK_TIME() {
for h in ${HOSTS[*]}; do ssh $h "echo && hostname -f && chronyc -a tracking |grep 'Leap status'"; done;
}

## CHECK ACCESS - INTERNET/PROXY/REGISTRY
DESC_CHECK_ACCESS="Verification de l'acces des noeuds cibles aux reseaux: public et stockage?${bold}"
COMMAND_CHECK_ACCESS() {
echo -e "Reseau Public (registry.suse.com):"
for h in ${HOSTS[*]}; do ssh $h "echo && hostname -f && ping -c1 registry.suse.com > /dev/null  && echo 'registry.suse.com: OK' || echo 'registry.suse.com: FAIL'"; done;
echo
echo -e "Reseau de Stockage:"
echo -e "Sauf pour la machine admin (isolation réseau)"
for h in ${HOSTS[*]}; do ssh $h "echo && hostname -f && ping -c1 $STORAGE_TARGET > /dev/null  && echo 'Acces Stockage: OK' || echo 'Acces Stockage: FAIL'"; done;
}

## DOCKER INSTALL
DESC_DOCKER_INSTALL="$pkg_mgr_type - Installation, activation et demarrage de Docker sur les noeuds?${bold}"
DESC_DOCKER_INSTALL_YUM="$pkg_mgr_type - Installation, activation et demarrage de Docker sur les noeuds?\n Docker version: ${DOCKER_VERSION}${bold}"
COMMAND_DOCKER_INSTALL_ZYPPER() {
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ; zypper ref ; zypper --non-interactive in docker"; done;
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ; systemctl enable docker ; systemctl start docker && echo 'Docker is activated' || echo 'Docker could not start'"; done;
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ; useradd -G docker ${DOCKER_USER} && echo \"${DOCKER_USER} user is created\" || echo \"Failed to create ${DOCKER_USER} user\" && mkdir /home/${DOCKER_USER}/.ssh && chown ${DOCKER_USER}:${DOCKER_USER} /home/${DOCKER_USER}/.ssh && chmod 700 /home/${DOCKER_USER}/.ssh && cp /root/.ssh/authorized_keys /home/${DOCKER_USER}/.ssh/ && chown ${DOCKER_USER}:${DOCKER_USER} /home/${DOCKER_USER}/.ssh/authorized_keys && chmod 600 /home/${DOCKER_USER}/.ssh/authorized_keys "; done;
}
COMMAND_DOCKER_INSTALL_YUM() {
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ; yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.107-3.el7.noarch.rpm"; done;
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ; yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/slirp4netns-0.4.3-4.el7_8.x86_64.rpm"; done;
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ; curl -s http://releases.rancher.com/install-docker/${DOCKER_VERSION}.sh | /bin/bash"; done;
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ; systemctl enable docker ; systemctl start docker && echo 'Docker is activated' || echo 'Docker could not start'"; done;
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ; useradd -G docker ${DOCKER_USER} && echo \"${DOCKER_USER} user is created\" || echo \"Failed to create ${DOCKER_USER} user\" && mkdir /home/${DOCKER_USER}/.ssh && chown ${DOCKER_USER}:${DOCKER_USER} /home/${DOCKER_USER}/.ssh && chmod 700 /home/${DOCKER_USER}/.ssh && cp /root/.ssh/authorized_keys /home/${DOCKER_USER}/.ssh/ && chown ${DOCKER_USER}:${DOCKER_USER} /home/${DOCKER_USER}/.ssh/authorized_keys && chmod 600 /home/${DOCKER_USER}/.ssh/authorized_keys "; done;
}

## DOCKER PROXY
DESC_DOCKER_PROXY="Configurer Docker pour utiliser le proxy?${bold}"
COMMAND_DOCKER_PROXY() {
for h in ${HOSTS[*]}; do ssh $h "echo ; hostname -f ;
sudo mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://${_HTTP_PROXY}"
Environment="HTTPS_PROXY=http://${_HTTPS_PROXY}"
Environment="NO_PROXY=${_NO_PROXY}"
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker"
done
}

## ACTIVATION IP FORWARDING
DESC_IPFORWARD_ACTIVATE="Activation de l'IP forwarding?${bold}"
COMMAND_IPFORWARD_ACTIVATE() {
for h in ${HOSTS[*]};do ssh $h "echo; hostname -f;sed -i '/net.ipv4.ip_forward.*/d' /etc/sysctl.conf; echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf; sed '/^#/d' /etc/sysctl.conf;sysctl -p" ; done
}

## DESACTIVATION DU SWAP
DESC_NO_SWAP="Desactivation du swap?${bold}"
COMMAND_NO_SWAP() {
for h in ${HOSTS[*]};do ssh $h 'sed -i "/swap/ s/defaults/&,noauto/" /etc/fstab';done
for h in ${HOSTS[*]};do ssh $h "echo; hostname -f; grep swap /etc/fstab; swapoff -a; free -g";done
}

## OUTILS K8S
DESC_K8S_TOOLS="$pkg_mgr_type - Installation des outils Kubernetes en local?${bold}"
COMMAND_K8S_TOOLS_ZYPPER() {
zypper -n in kubernetes1.18-client
}
COMMAND_K8S_TOOLS_YUM() {
yum install -y kubectl
}

## CHECK FIREWALLD
DESC_FIREWALL="$pkg_mgr_type - Verification de l'etat du firewall (doit etre desactive)?${bold}"
COMMAND_FIREWALL() {
for h in ${HOSTS[*]};do
hostname -f
systemctl status firewalld
if [[ $? -ne 0 ]]
then 
  echo "${bold}Firewall service seems down, this is OK!${normal}"
  echo
else 
  echo "${bold}Firewall service seems up, this is NOT OK!${normal} Please disable and shutdown firewall on target nodes."
  echo
fi
done
}

## CHECK DEFAULT GW EXIST
DESC_DEFAULT_GW="$pkg_mgr_type - Verification qu'une gateway par défaut existe?${bold}"
DEFAULT_GW='172.16.0.254'
COMMAND_DEFAULT_GW() {
echo
for h in ${HOSTS[*]};do 
  ROUTE_TABLE=$(ssh $h cat /proc/net/route | awk '$2==00000000')
  CURRENT_GATEWAY=$(for i in `echo $ROUTE_TABLE | awk '{print $3}'| sed -E 's/(..)(..)(..)(..)/\4 \3 \2 \1/'`;do printf "%d." $((16#$i));done |sed 's/.$//';echo)
  #echo $CURRENT_GATEWAY
  echo ${bold};ssh $h hostname|tr -d "\n";echo -n ${normal};echo -n ": default gateway is${bold} $CURRENT_GATEWAY"${normal};
done
echo
echo "A Default Gateway should be set on all nodes (even if non-existent/non-working)"
#if grep -qi 'GATEWAY=' /etc/sysconfig/network;
#then
#  GW=`cat /etc/sysconfig/network |grep 'GATEWAY='|awk '{print $1}'`
#  echo "A Default Gateway should be set on all nodes"
#  echo "Local default gateway: $GW"
#else
#  echo "A Default Gateway is not set. This is needed for K8S deployment even if this gateway does not exist"
#  read -p "${bold}Which default gateway would you like to setup on you future Rancher nodes? ${normal}" DEFAULT_GW
#  DEFAULT_GW=${DEFAULT_GW:-172.16.0.254}
#  for h in ${HOSTS[*]};do ssh $h "echo; hostname -f;sed -i '/GATEWAY=*/d' /etc/sysconfig/network; echo "GATEWAY=$DEFAULT_GW" >> /etc/sysconfig/network; sed '/^#/d' /etc/sysconfig/network; systemctl restart network" ; done  
#  hostname -f;sed -i '/GATEWAY=*/d' /etc/sysconfig/network; echo "GATEWAY=$DEFAULT_GW" >> /etc/sysconfig/network; sed '/^#/d' /etc/sysconfig/network; systemctl restart network
#fi
}
####################BEGIN PRE-CHECK PACKAGES & FIREWALL#######################
question_yn "$DESC_CHECK_PACKAGE" "COMMAND_CHECK_PACKAGE_RPM curl expect"
question_yn "$DESC_FIREWALL" COMMAND_FIREWALL
####################END PRE-CHECK PACKAGES & FIREWALL#########################

####################BEGIN SSH KEYS EXCHANGE###################################
question_yn "$DESC_SSH_KEYS" COMMAND_SSH_KEYS
question_yn "$DESC_SSH_DEPLOY" COMMAND_SSH_DEPLOY
question_yn "$DESC_SSH_CONNECT_TEST" COMMAND_SSH_CONNECT_TEST
####################END SSH KEYS EXCHANGE#####################################

if [[ ! -z ${_HTTP_PROXY} ]] || [[ ! -z ${_HTTPS_PROXY} ]] || [[ ! -z ${_NO_PROXY} ]]
then
question_yn "$DESC_SET_PROXY" COMMAND_SET_PROXY
fi

if [[ $pkg_mgr_type == 'zypper' ]]
then 
question_yn "$DESC_REPOS" COMMAND_REPOS_ZYPPER
#question_yn "$DESC_ADDREPOS" COMMAND_ADDREPOS_ZYPPER
question_yn "$DESC_NODES_UPDATE" COMMAND_NODES_UPDATE_ZYPPER
question_yn "$DESC_DOCKER_INSTALL" COMMAND_DOCKER_INSTALL_ZYPPER
question_yn "$DESC_K8S_TOOLS" COMMAND_K8S_TOOLS_ZYPPER

elif [[ $pkg_mgr_type == 'yum' ]]
then
question_yn "$DESC_REPOS" COMMAND_REPOS_YUM
#question_yn "$DESC_ADDREPOS" COMMAND_ADDREPOS_YUM
question_yn "$DESC_ADDREPOS_YUM_K8STOOLS" COMMAND_ADDREPOS_YUM_K8STOOLS
question_yn "$DESC_NODES_UPDATE" COMMAND_NODES_UPDATE_YUM
question_yn "$DESC_DOCKER_INSTALL_YUM" COMMAND_DOCKER_INSTALL_YUM
question_yn "$DESC_K8S_TOOLS" COMMAND_K8S_TOOLS_YUM
fi

if [[ ! -z ${_HTTP_PROXY} ]] || [[ ! -z ${_HTTPS_PROXY} ]] || [[ ! -z ${_NO_PROXY} ]]
then
question_yn "$DESC_DOCKER_PROXY" COMMAND_DOCKER_PROXY
fi

question_yn "$DESC_DEFAULT_GW" COMMAND_DEFAULT_GW
question_yn "$DESC_CHECK_TIME" COMMAND_CHECK_TIME
question_yn "$DESC_CHECK_ACCESS" COMMAND_CHECK_ACCESS
question_yn "$DESC_IPFORWARD_ACTIVATE" COMMAND_IPFORWARD_ACTIVATE
question_yn "$DESC_NO_SWAP" COMMAND_NO_SWAP

echo
echo "-- FIN --"
echo "Prochaine étape 02-rke_deploy.sh"
