############################################################################
# get repo                                                             #
############################################################################
    if [ -z "$RHDN_ACTIVATION_KEY" ]; then
      echo "RHDN_ACTIVATION_KEY undefined, will not be attached"
      exit 1
    else
      echo "RHDN_ACTIVATION_KEY detected, attaching to RHDN"
      subscription-manager register \
        --username ${RHDN_USER} \
        --password ${RHDN_PASS} \
        --autosubscribe --force

      # Add EPEL
      echo -e "\nInstalling additional repos\n"
      dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
      curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo >\
        "/etc/yum.repos.d/github-cli.repo"
      echo
      /usr/bin/crb enable

      # Install required Software
      dnf install -y rpm-utils

      # Final Software Update 
      echo -e "\nCollecting $1\n"
      reposync -p /vagrant --download-metadata --repo=$1
    fi
    echo -e "\nDone fetching. Rebooting.\n"