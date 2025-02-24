#!/bin/bash
VERSION=$(grep -oP '(?<=VERSION_ID=")[^.]+' /etc/os-release)
export PATH=$PATH:$PWD/scripts
rm -v /etc/rhsm-host /etc/yum.repos.d/ubi.repo
subscription-manager register --username ${1} --password ${2}
echo "Installing Software"
dnf install -y dnf-plugins-core yum-utils mkisofs isomd5sum tree procps-ng ncurses
echo "Registering Code Ready Builder Repo"
/usr/bin/crb enable
echo "Registering epel Repo"
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-${VERSION}.noarch.rpm
echo "Registering docker-ce-stable Repo"
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
echo "Registering hashicorp Repo"
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
echo -e "\nAvailable Repositories:\n$(dnf repolist)\n"