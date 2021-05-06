### Common
TXT_END="FIN"
TXT_NEXT_STEP="Prochaine étape"
TXT_READ_HOST_FILE="Lecture de la liste des hotes dans"
TXT_LIST_HOSTS="Liste des hotes cibles"
TXT_IS_PRESENT="est present"
TXT_NOT_PRESENT="est absent"

### Script 01
DESC_CHECK_PACKAGE="Vérification de la présence des paquets ?"
TXT_CHECK_PACKAGE_PRESENT="Recherche de la presence du paquet"
DESC_SSH_KEYS="Création d'une paire de clefs SSH en local ?"
DESC_SSH_DEPLOY="Déploiement de la clef publique vers les noeuds ?"
TXT_ENTER_CLIENT_PWD="Veuillez entrer le mot de passe des clients"
DESC_SSH_CONNECT_TEST="Test de connexion en masse ?"
DESC_COPY_PROXY_CA="Copie de la clef privée du proxy vers les clients. Appliquer ces paramètres ? (spécifique Lab SUSE FR)"
DESC_SET_PROXY="Des variables PROXY sont definies dans le fichier ./00-vars.sh. Appliquer ces parametres ? \n _HTTP_PROXY=${_HTTP_PROXY} \n _HTTPS_PROXY=${_HTTPS_PROXY} \n _NO_PROXY=${_NO_PROXY}"
DESC_REPOS="$pkg_mgr_type - Liste des repos sur les noeuds"
DESC_ADDREPOS="$pkg_mgr_type - Ajout des repos containers-modules sur les noeuds et en local ?"
DESC_ADDREPOS_YUM_K8STOOLS="$pkg_mgr_type - Ajout du repo public pour les outils K8S (kubectl...) ?"
DESC_NODES_UPDATE="$pkg_mgr_type - Mise à jour de tous les noeuds ?"
DESC_CHECK_TIME="Vérification de la date et heure sur les noeuds ?"
DESC_CHECK_ACCESS="Vérification de l'accès des noeuds cibles aux reseaux: public et stockage ?"
DESC_DOCKER_INSTALL="$pkg_mgr_type - Installation, activation et demarrage de Docker sur les noeuds ?"
DESC_DOCKER_INSTALL_YUM="$pkg_mgr_type - Installation, activation et demarrage de Docker sur les noeuds?\n Docker version: ${DOCKER_VERSION}"
DESC_CREATE_DOCKER_USER="Creation de l'utilisateur docker pour RKE\n Docker user: ${DOCKER_USER}\n Docker group: ${DOCKER_GROUP}"
DESC_DOCKER_PROXY="Configurer Docker pour utiliser le proxy ?"
DESC_IPFORWARD_ACTIVATE="Activation de l'IP forwarding ?"
DESC_NO_SWAP="Desactivation du swap ?"
DESC_K8S_TOOLS="$pkg_mgr_type - Installation des outils Kubernetes en local ?"
DESC_FIREWALL="$pkg_mgr_type - Vérification de l'etat du firewall (doit être désactivé) ?"
DESC_DEFAULT_GW="$pkg_mgr_type - Vérification qu'une gateway par défaut existe ?"

### Script 02
DESC_RKE_INSTALL="Installation de RKE en local? \n RKE version: ${RKE_VERSION}"
DESC_RKE_CONFIG="Creation du fichier de configuration "cluster.yml"? \n Version K8S: $KUBERNETES_VERSION"
DESC_RKE_DEPLOY="Installation de RKE en local?"
DESC_KUBECONFIG="Mise en place du fichier de controle Kubeconfig?"
DESC_HELM_INSTALL="Installation de HELM? \n Helm Version: ${HELM_VERSION}"
DESC_HELM_REPOS="Ajout des repos HELM SUSE + Rancher (internet!)?"

### Script 03
DESC_CERTMGR_INSTALL="Installation de Cert Manager?"
DESC_TEST_FQDN="Test du nom dns ${LB_RANCHER_FQDN}?"
DESC_RANCHER_INSTALL="Installation de Rancher Management (${LB_RANCHER_FQDN})?"
DESC_INIT_ADMIN="Initialisation d'un utilisateur admin?"