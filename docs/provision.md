# How to provision a new web server

## Create the server, set up access

- following https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04
- provision an Ubuntu 20.04 machine from DigitalOcean, giving it your SSH key
- modify `~/.ssh/config` adding the host name, e.g. `worde`, including `User deploy`
- log in as root `ssh root@worde`
- update all packages `apt update && apt upgrade -y`
- install `apt install -y unattended-upgrades`
- configure unattended updates, follow https://help.ubuntu.com/community/AutomaticSecurityUpdates
- create a user `adduser deploy`
- add user to sudoers `usermod -aG sudo deploy`
- allow ssh `ufw allow OpenSSH`, enable firewall `ufw enable`, confirm it works `ufw status`
- copy the SSH key over (run this still from the server) `rsync --archive --chown=deploy:deploy ~/.ssh /home/deploy`
- try logging in, `ssh worde`
- disable password auth, `sudo vim /etc/ssh/sshd_config`
- set `PasswordAuthentication no` and `PermitRootLogin no`, save & close
- `sudo systemctl restart ssh`
- verify `ssh root@worde` fails

## Install nginx

- set up DNS to point to the server's IP
- install nginx `sudo apt update && sudo apt install -y nginx`
- allow nginx through the firewall `sudo ufw allow 'nginx full'`
- confirm nginx is running
    - `systemctl status nginx`
    - visit the server IP in the browser
- save the nginx site config under `/etc/nginx/sites-available/regex.help`
```
upstream phoenix {
  server 127.0.0.1:4000;
}

server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name regex.help;

  location / {
    allow all;
    proxy_pass http://phoenix;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Cluster-Client-Ip $remote_addr;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
  }
}

```
- enable, test and reload the new nginx config
```bash
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/regex.help /etc/nginx/sites-enabled/
sudo nginx -t
sudo service nginx restart
```

## Deploy the app

- locally, set up the app to [use runtime config](https://hexdocs.pm/phoenix/releases.html#runtime-configuration) so `SECRET_KEY_BASE` is not needed for `mix release`
- locally, run the deploy script to deploy the app to the server (`/script/deploy`)
- locally, run `mix phx.gen.secret` to generate the key
- on the server, create the env file:
```bash
cat >> /home/deploy/secretwords.env<< EOF
export PORT=4000
export HOSTNAME=words.gryka.net
export SECRET_KEY_BASE=<generated_key>
EOF
```
- source the env file in profile `echo "source /home/deploy/words.gryka.net.env" >> .profile` # TODO: is this needed?
- start the app manually `~/srv/secretwords/bin/secretwords start`
- check that it's available at the domain
- stop the app


## Set up tls

- if you want to be fancy, set up a DNS CAA record https://blog.qualys.com/product-tech/2017/03/13/caa-mandated-by-cabrowser-forum
- install certbot by following https://certbot.eff.org/:
```bash
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx
sudo nginx -t # ensure nginx config is correct
sudo service nginx restart
```

## Set up systemd service
- create a systemd service `sudo vim /lib/systemd/system/deploy-example.service`:
```conf
[Unit]
Description=Secretwords Service
After=local-fs.target network.target

[Service]
Type=simple
User=deploy
Group=deploy
ExecStart=/home/deploy/srv/secretwords/bin/secretwords start
ExecStop=/home/deploy/srv/secretwords/bin/secretwords stop
EnvironmentFile=/home/deploy/words.gryka.net.env
Environment=LANG=en_US.UTF-8
Environment=MIX_ENV=prod

LimitNOFILE=65535
UMask=0027
SyslogIdentifier=secretwords
Restart=always


[Install]
WantedBy=multi-user.target
```