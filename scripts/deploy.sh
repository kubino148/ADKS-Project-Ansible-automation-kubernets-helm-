
install_voucherstore(){
    kubectl create ns voucherstore
    helm repo update
    helm dependency update ../helm
    helm install voucherstore ../helm -n voucherstore
}

cluster_create() {
  if ! docker info &>/dev/zero; then printf "Some problem has occured with your Docker.\nAre sure that it is running?\n"; fi
  if k3d cluster create --no-lb --k3s-server-arg '--no-deploy=traefik' ; then
    until kubectl get all &>/dev/zero; do sleep 1; done
  else
    printf "The cluster has probably already been created\n"
  fi
}

nginx_add_hosts() {
  printf "Adding all necessary hosts to your /etc/hosts file\n"
  local nginx_lb_ip=$(kubectl get svc -n nginx nginx-nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

  printf "\n\n%s\t%s\n" $nginx_lb_ip "voucherstore.pl" | sudo tee -a /etc/hosts
  printf "%s\t%s\n" $nginx_lb_ip "grafana.voucherstore.pl" | sudo tee -a /etc/hosts
}


nginx_install_release() {
  printf "Please wait, an Nginx Ingress Controller release is being created\n"
  kubectl create ns nginx

  helm repo update
  helm -n nginx install nginx stable/nginx-ingress -f charts/nginx.yaml --wait

  nginx_add_hosts

  printf "Your Nginx Ingress Controller relase is now ready to be used\n"
}

dependencies_curl() {
  if ! builtin type -P curl &>/dev/null; then
    case "$OS" in
      "Arch Linux")
        yay -S curl || pacman -S curl
        ;;
      "Ubuntu"|"Debian GNU/Linux")
        sudo apt-get update && sudo apt-get install -y install curl
        ;;
      *)
        printf "Distribution $OS is not supported\n"
    esac
  else
    printf "Curl is already installed!\n"
  fi
}


dependencies_docker() {
  if ! builtin type -P docker &>/dev/null; then
    case "$OS" in
      "Arch Linux")
        yay -S docker || pacman -S docker
        ;;
      "Ubuntu"|"Debian GNU/Linux")
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
           $(lsb_release -cs) \
           stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        ;;
      *)
        printf "Distribution $OS is not supported\n"
    esac
  else
    printf "Docker is already installed\n"
  fi
}


dependencies_kubectl() {
  if ! builtin type -P kubectl &>/dev/null; then
    case "$OS" in
      "Arch Linux")
        yay -S kubectl || pacman -S kubectl
        ;;
      "Ubuntu"|"Debian GNU/Linux")
        sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
        sudo apt-get update
        sudo apt-get install -y kubectl
        ;;
      *)
        printf "Distribution $OS is not supported\n"
    esac
  else
    printf "kubectl is already installed\n"
  fi
}


dependencies_helm() {
  if ! builtin type -P helm &>/dev/null; then
    case "$OS" in
      "Arch Linux")
        yay -S helm || echo "You need to have yay"
        ;;
      "Ubuntu"|"Debian GNU/Linux")
        curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
        ;;
      *)
        printf "Distribution $OS is not supported\n"
    esac
  else
    printf "Helm is already installed!\n"
  fi
}


dependencies_k3d() {
  if ! builtin type -P k3d &>/dev/null; then
    case "$OS" in
      "Arch Linux")
        yay -S rancher-k3d-bin | echo "You need to have yay"
        ;;
      "Ubuntu"|"Debian GNU/Linux")
        curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
        ;;
      *)
        printf "Distribution $OS is not supported\n"
    esac
  else
    printf "k3d is already installed\n"
  fi
}


dependencies_jq() {
  if ! builtin type -P jq &>/dev/null; then
    case "$OS" in
      "Arch Linux")
        yay -S jq || pacman -S jq
        ;;
      "Ubuntu"|"Debian GNU/Linux")
         sudo apt-get update && sudo apt-get install -y jq
        ;;
      *)
        printf "Distribution $OS is not supported\n"
    esac
  else
    printf "jq is already installed\n"
  fi
}


dependencies_nc() {
  if ! builtin type -P nc &>/dev/null; then
    case "$OS" in
      "Arch Linux")
        yay -S openbsd-netcat || pacman -S openbsd-netcat
        ;;
      "Ubuntu"|"Debian GNU/Linux")
         sudo apt-get update && sudo apt-get install -y netcat
        ;;
      *)
        printf "Distribution $OS is not supported\n"
    esac
  else
    printf "Netcat is already installed\n"
  fi
}



dependencies_all() {
  printf "Installing all k3d dependencies\n"
  dependencies_curl
  dependencies_docker
  dependencies_kubectl
  dependencies_helm
  dependencies_jq
  dependencies_nc
  dependencies_k3d
}

helm_repositories() {
  printf "Adding the most popular Helm chart repositories\n"
  helm repo add stable https://charts.helm.sh/stable
  helm repo add elastic https://helm.elastic.co
  helm repo add haproxytech https://haproxytech.github.io/helm-charts
  helm repo add incubator https://charts.helm.sh/incubator
  helm repo add jetstack https://charts.jetstack.io
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo add gitlab https://charts.gitlab.io/
  helm repo add openfaas https://openfaas.github.io/faas-netes/
  helm repo add k8s-land https://charts.k8s.land
  helm repo add mailu https://mailu.github.io/helm-charts/
  helm repo add codecentric https://codecentric.github.io/helm-charts
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  helm repo add grafana https://grafana.github.io/helm-charts
  printf "Repositories are now added\n"
}


dependencies_curl
dependencies_docker
dependencies_kubectl
dependencies_helm
dependencies_jq
dependencies_nc
dependencies_k3d

helm_repositories

cluster_create

nginx_install_release

install_voucherstore
