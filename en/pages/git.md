# Git Version Control #

We follow the [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/) development model to manage our software development with git. Our repositories can be found our [github page](https://github.com/OptimalDesignLab). 

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

Since this is cloning over https and not ssh, you'll have to enter your password every time you interact with the remote repo. If you have two-factor authentication set up for your github account, you cannot use your password. You'll need to set up a [personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) and use this in place of your password when prompted. You'll need to save this token somewhere secure, since github will not show it to you after the first time you created it.

If you want to set it up so that you don't need to enter your password/token each time, you can do that using a `.netrc` file and `gpg`.

Note: the following process requires `git` version 1.8.3+, so will only work on DCS or ERP. The DRP cluster and landing pads have `git` version 1.7.1.

Create a file named `.netrc` in your home directory with the contents:

```bash
machine github.com
login <your_github_username>
password <your_github_password_or_access_token>
protocol https
```

Next, you should encrypt this file using [gpg](https://www.gnupg.org) (available on CCI). Use `gpg --gen-key` to generate a public/private key pair. The key pair may take a while to generate. Once finished, you can use `gpg --list-key` to view your keys. Once you've got your keys, use `gpg` to encrypt your `.netrc` file, (from your home directory) with `gpg --encrypt --recipient <the_same_email@you_used_generating_the_key> .netrc`.

To allow `git` to automatically decrypt this file and access its contents on push/pulls, you need to tell it how. Download [this](https://raw.githubusercontent.com/git/git/master/contrib/credential/netrc/git-credential-netrc.perl) file and make sure you have executable permissions for it. Put it in `~/.local/bin` (or anywhere else in your `$PATH`). Next, configure git to use the above script with `git config --global credential.helper "netrc.perl -f ~/.netrc.gpg"`. You can add `-v` and `-d` flags for verbose/debug output if desired.

Once you've set the credential helper to use the downloaded script, you will be able to push/pull without being prompted for your github password every time. Make sure to delete the original `.netrc` file so you don't store your password/token in plain text.
