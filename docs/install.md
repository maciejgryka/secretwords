# Set up the server
- install nginx `sudo apt update && sudo apt install nginx`
- allow nginx through the firewall `sudo ufw allow 'Nginx HTTP'` (TODO: change later to HTTPS)
- confirm nginx is running
    - `systemctl status nginx`
    - visit the server IP in the browser
- set up DNS to point to the server's IP
- locally, run `mix phx.gen.secret` to generate the key
- set up env on the server `echo "SECRET_KEY_BASE='...'" >> .profile`
- set up the app to [use runtime config](https://hexdocs.pm/phoenix/releases.html#runtime-configuration) so `SECRET_KEY_BASE` is not needed for `mix release`
