AUTHOR = Johan Adriaans <johan@driaans.nl>

export ANSIBLE_HOST_KEY_CHECKING = False

help:
	@echo ""
	@echo "Please use \`make <target>' where <target> is one of"
	@echo ""
	@echo "  init              Initiate management environment."
	@echo "  clean             Clean un environment, also destroying servers"
	@echo "  start             Bring up the vagrant cluster"
	@echo "  sleep             Halt vagrant machines without destroying them"
	@echo "  wake              Wake up machines, also fixing galera cluster problems"
	@echo "  bootstrap-servers Just bootstrap the servers to a running etcd/fleet cluster"
	@echo "  bootstrap-cluster Start all cluster units"
	@echo "  log               Show all logs"

init:
	@echo "Initiating environment"
	@eval `ssh-agent` && ssh-add && ssh-add ~/.vagrant.d/insecure_private_key

clean:
	@vagrant destroy -f
	@sed -i -e '/127.0.0.1/d' ~/.ssh/known_hosts
	@rm -rf .vagrant_nfs_share

bootstrap-servers:
	@ansible-playbook -i inventory/vagrant playbook_bootstrap.yml

bootstrap-cluster:
	@ansible-playbook -i inventory/vagrant playbook_cluster.yml

start: init
	@echo "Bringing up vagrant cluster"
	@vagrant up
	-@eval `ssh-agent` && ssh-add ~/.vagrant.d/insecure_private_key

sleep:
	@vagrant halt

wake:
	@vagrant up

log:
	@vagrant ssh cluster-member-1 --command "fleetctl ssh -A -unit log-server sudo journalctl -f -D /var/log/journal/remote"
