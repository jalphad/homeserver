## Users

Add a file called 'personal-accounts.nix' to this 
folder to add data for personal accounts to this
server. Data will be merged into top-level `users`
in `./config/users.nix`. This file should therefore
be structured as in the following example:
```nix
{
  users = {
    user1 = {
      isNormalUser = true;
      createHome = true;
    };
  };
  groups = {
    somegroup = {};
  };
}
```