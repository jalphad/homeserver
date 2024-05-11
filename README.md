# homeserver

## Install
- Boot from usb
- Prepare filesystem
- Mount OS partition on /mnt
- Mount Boot partition on /mnt/boot
- Execute:
```nix
nixos-install --root /mnt --flake /mnt/etc/nixos#homeserver
```
- Reboot

## Update
- Git pull latest update to `/etc/nixos`
- Execute:
```nix
sudo nixos-rebuild switch --flake /etc/nixos/#homeserver --impure
```
*Adding `--impure` because the personal-accounts.nix file is not part of the flake.*


## WIP
### More detailed description on setting up disks
### Use variables for input in Nix config

### Automate initial container setup
Automatically start/configure
- Traefik
- Keycloak
- Portainer
- Monitoring/Dashboards (currently netdata)
- Lego (done!)
- FreeRadius

### SSO
Describe how to set it all up (and preferably automate setup)

Jellyfin            -> sso plugin > done
Paperless           -> no solution
Nextcloud           -> plugin > done
Sonarr
Radarr
Heimdall/Organizr

Traefik

### Jellyfin
Custom menu link to Jellyseerr
https://jellyfin.org/docs/general/clients/web-config/#custom-menu-links

### LDAP
Using OpenLDAP because it can be used as a backend for Samba

Use `slaptest` to convert schema files to ldif files:
```shell
mkdir -p /tmp/ldif/out
touch /tmp/ldif/conf
echo 'include /path/to/schema.schema' > /tmp/ldif/conf
slaptest -f /tmp/ldif/conf -F /tmp/ldif/out
```
Generated ldif is under `/tmp/ldif/out/cn=config/cn=schema`

#### sambaSID
Get samba server localsid: `net getlocalsid`

`sambaSID = $LOCALSID "-" ($UIDNUMBER * 2 + 1000)`

#### Create/Delete objects
```shell
ldapadd -x -D "cn=admin,dc=lan,dc=mejora,dc=dev" -W -H ldap:// -f <path to ldif>
```

```shell
ldapdelete -x -D "cn=admin,dc=lan,dc=mejora,dc=dev" -W -H ldap:// -f <dn>
```

To (re)set a password
```shell
ldappasswd -x -D "cn=admin,dc=lan,dc=mejora,dc=dev" -W -H ldap:// -S <dn>
```

#### Troubleshooting
*List objectClasses*:
```shell
ldapsearch -H ldap:// -x -s base -b "cn=subschema" objectclasses
```
*List supported extensions*
```shell
ldapsearch -H ldap:// -x -s base -b "" "(objectclass=*)" supportedExtension
```
*List objects under dc=lan,dc=mejora,dc=dev*
```shell
ldapsearch -H ldap:// -x -D "<admin DN>" -W -b "dc=lan,dc=mejora,dc=dev"
```

### Samba
To support user authentication against ldap, you also need to add the `users.ldap` configuration in the nix config. 

### FreeRadius

Provides: wifi auth with sso through ldap
Auth method: eap-peap (mschapv2)

Chose eap-peap because it's the most widely supported scheme for username/pw auth.
Got eap-ttls working with Linux workstation but iPhone refused to authenticate.

#### Configuration

**clients.conf**
Contains config for the clients (APs) connecting to the Radius server

**mods-enabled**
- eap: *we're doing eap*
- ldap: *for getting users from ldap*
- mschap: *doing mschapv2 auth*
- pap: *transform returned NT-Password from bytes to something usable by mschap module*
- radutmp: *session backend*

**sites-enabled**
- home-server: *start eap session*
- inner-tunnel: *handle peap session*

**TODO**
generate certs using LetsEncrypt