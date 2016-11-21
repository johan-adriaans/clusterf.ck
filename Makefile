AUTHOR = Johan Adriaans <johan@driaans.nl>

export ANSIBLE_HOST_KEY_CHECKING = False

help:
	@echo ""
	@echo "Please use \`make <target>' where <target> is one of"
	@echo ""
	@echo "  start             Bring up the vagrant cluster"
	@echo "  sleep             Halt vagrant machines without destroying them"
	@echo "  wake              Wake up machines, also fixing galera cluster problems"
	@echo "  bootstrap-servers Just bootstrap the servers to a running etcd/fleet cluster"
	@echo "  bootstrap-cluster Start all cluster units"
	@echo "  log               Show all logs"
	@echo "  clean             Clean un environment, also destroying servers"

start:
	@echo "Bringing up vagrant cluster"
	@-ssh-keygen -R [127.0.0.1]:2222 2>/dev/null
	@-ssh-keygen -R [127.0.0.1]:2200 2>/dev/null
	@-ssh-keygen -R [127.0.0.1]:2201 2>/dev/null
	@vagrant up

bootstrap-servers:
	@ansible-playbook -i inventory/vagrant playbook_bootstrap.yml --private-key "$$(vagrant ssh-config cluster-member-1 | grep IdentityFile | awk '{print $$2}' | tr -d \")"

bootstrap-cluster:
	@echo "Installing services"
	@ansible-playbook -i inventory/vagrant playbook_cluster.yml --private-key "$$(vagrant ssh-config cluster-member-1 | grep IdentityFile | awk '{print $$2}' | tr -d \")"

sleep:
	@vagrant halt

wake:
	@vagrant up

log:
	@eval `ssh-agent` && ssh-add "$$(vagrant ssh-config cluster-member-1 | grep IdentityFile | awk '{print $$2}' | tr -d \")" && vagrant ssh cluster-member-1 --command "fleetctl ssh -A -unit log-server sudo journalctl -f -D /var/log/journal/remote"

clean:
	@vagrant destroy -f
	@-ssh-keygen -R [127.0.0.1]:2222
	@-ssh-keygen -R [127.0.0.1]:2200
	@-ssh-keygen -R [127.0.0.1]:2201
	@rm -f .vagrant_nfs_share
