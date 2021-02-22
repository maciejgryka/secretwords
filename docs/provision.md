- following https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04
- provision an Ubuntu 20.04 machine from DigitalOcean, giving it your SSH key
- modify `~/.ssh/config` adding the host name, e.g. `worde`, including `User mgryka`
- log in as root `ssh root@worde`
- create a user `adduser mgryka`
- add user to sudoers `usermod -aG sudo mgryka`
- allow ssh `ufw allow OpenSSH`, enable firewall `ufw enable`, confirm it works `ufw status`
- copy the SSH key over `rsync --archive --chown=mgryka:mgryka ~/.ssh /home/mgryka`
- try logging in, `ssh worde`, update packages `sudo apt update && sudo apt upgrade`
- disable password auth, `sudo vim /etc/ssh/sshd_config`
- set `PasswordAuthentication no` and `PermitRootLogin no`, save & close
- `sudo systemctl restart ssh`
- verify `ssh root@worde` fails