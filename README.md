# Dropkit Starter CC

This starter copies user configs & preferred tools to the root of a Digital Ocean droplet setup following the [Trail of Bits' Dropkit](https://github.com/trailofbits/dropkit) repo. 

## Installation

Follow [dropkit setup steps](https://github.com/trailofbits/dropkit#installation). 

useful commands

```shell
tailscale status
tailscale ping <droplet>
dropkit off <droplet>    # if ip address differs from tailscale's
dropkit on <droplet>
```

After 

```shell
ssh dropkit.<droplet>
```

download this template repo / a repurposed one.

### Download repo

```shell
git clone https://github.com/vrndstudio/dropkit-starter-cc
cd dropkit-starter-cc
bash install.sh
```

installs [xyz]

### Set git identity

Run after install

```shell
bash set-git-identity.sh
```

## Usage

### SSH Git Cloning

One time auth for cloning, using a fine-grained github PAT

```shell
read -s GH_TOKEN                    # paste token, press Enter, nothing echoed
echo "len: ${#GH_TOKEN}"            # sanity-check it's the expected ~93 chars
git clone https://x-access-token:${GH_TOKEN}@github.com/you/repo.git
cd repo
git remote set-url origin https://github.com/you/repo.git   # strip token from stored URL
unset GH_TOKEN
```


