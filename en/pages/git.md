# Git Version Control #

## Using git on CCI systems ##

The CCI systems are normally not allowed to initiate outbound network communications. This means you cannot clone a github repository as you normally would on your computer. However, there is an exception that allows accessing github over https, but requires some special configuration. These instructions are compiled together from [these](https://secure.cci.rpi.edu/wiki/index.php?title=Proxy) [sources](https://help.github.com/en/github/authenticating-to-github/accessing-github-using-two-factor-authentication#using-two-factor-authentication-with-the-command-line).

To allow access of git repos on CCI, first you need to define these environment variables (I recommend adding them to your `.bashrc` file):

```bash
export http_proxy=http://proxy:8888
export https_proxy=$http_proxy
```

Then, you may navigate to the directory where you want to clone the repository (should be barn), and execute

```bash
git clone https://<your_github_username>@github.com/path/to/repo.git
```

For example, to clone `mach`, I would execute

```bash
git clone https://tuckerbabcock@github.com/OptimalDesignLab/mach.git
```

Since this is cloning over https and not ssh, you'll have to enter your password every time you interact with the remote repo. There are ways around this that involve git caching your password, but it stores it unencrypted on the file system and you rely on file system permissions to keep your password hidden. **This is not secure**.

**NOTE**: if you have two-factor authentication set up for your github account, you cannot use your password. You'll need to set up a [personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) and use this in place of your password when prompted. You'll need to save this token somewhere secure, since github will not show it to you after the first time you created it.

If don't want to need to remember your access token, you can clone the repository with it included instead. **This is not secure. Git will still cache the access token if you do this, and now it will also be in your bash history.** To clone a repo this way, execute

```bash
git clone https://<your_github_username>:<your_access_token>@github.com/path/to/repo.git
```
