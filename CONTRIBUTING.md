# Contributing guidelines

We welcome any kind of contributions to our software, from simple
comment or question to a full [pull
request](https://help.github.com/articles/about-pull-requests/). Please
read and follow our contributing guidelines.

## Contributing via GitHub

Note when we want to work with `STEMMUS_SCOPE` repository on a new computer for
the first time, we need to configure a few things following steps 1 to 4 below.

### 1. Enable two-factor authentication

It is strongly recommended using two-factor authentication. Here is the link of
[Configuring two-factor
authentication](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication).

### 2. Set ssh connection

With SSH keys, you can connect to GitHub without supplying your username and
personal access token at each visit. Please follow the instructions below. If
you lik eto know more, see [Connecting to GitHub with
SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

#### 2.1. Checking for existing SSH keys

Open a Terminal and run the command below: 

```bash
ls -la ~/.ssh
```

This command lists the files with extension `.pub` like `id_rsa.pub` in the
`.ssh` directory, if they exist. If you receive an error that `~/.ssh` doesn't
exist, or you don't see any files with extension `.pub`, you do not have an
existing SSH key pair. So, continue with step **2.2**. Otherwise, skip step 2.2 and
continue with step **2.3**.

#### 2.2. Generating a new SSH key

Open a terminal and run the command below but replace `your_user_email` with
your own GitHub email address:

```ssh
ssh-keygen -t ed25519 -C "your_user_email"
```

When you're prompted to "Enter a file in which to save the key," press `Enter`.
This accepts the default file location.

The next prompt asks "Enter passphrase (empty for no passphrase)", type a secure
passphrase. For more information, see [Working with SSH key
passphrases](https://docs.github.com/en/articles/working-with-ssh-key-passphrases).

#### 2.3. Adding your SSH key to the ssh-agent

Open a terminal and run the command below:

```bash
eval "$(ssh-agent -s)"
```

Then, run the command below:

```bash
ssh-add ~/.ssh/id_ed25519
```

This asks for your "passphrase" that was provided in the previous step. 

#### 2.4. Adding a new SSH key to your GitHub account

Please follow steps 1 to 8 in this [GitHub
instruction](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

### 3. Configure git

#### 3.1. Set name and email

Open a terminal, and run the commands below one by one but replace
`your_user_name` and `your_user_email` with your own GitHub information:

```bash
git config --global user.name "your_user_name"
git config --global user.email "your_user_email"
```

#### 3.2. Set line endings

Change the way Git encodes line endings on Linux as:

```bash
git config --global core.autocrlf input
```

#### 3.3. Set text editor

We can set `nano` as our favorite text editor, following:

```bash
git config --global core.editor "nano -w"
```

> We use `nano` here because it is one of the least complex text editors. Press
> `ctrl + O` to save the file, and then `ctrl + X` to exit `nano`.

#### 3.4. Check your settings

You can check your settings at any time:

```bash
git config --list
```

For more information, see lesson [Setting Up
Git](https://swcarpentry.github.io/git-novice/02-setup/index.html).

### 4. Clone the repository

Open a terminal and run the command:

```bash
git clone git@github.com:EcoExtreML/STEMMUS_SCOPE.git
```

> In this command, we clone the repository using `ssh` option. As we set the ssh
connection in [**Step 2**](#2-set-ssh-connection), this command here does not ask for our user name and
password. 