# Contributing guidelines

This repository includes the MATLAB source code of the STEMMUS-SCOPE model. We welcome any
kind of contributions to our software, from simple comments or questions to a full
[pull request](https://help.github.com/articles/about-pull-requests/). Please
read and follow our contributing guidelines.

## Contributing via GitHub

If you want to work with the `STEMMUS_SCOPE` repository for the first time, or on a new computer, 
you need to configure a few things following steps 1 through 5 below.

<details>
  <summary>Steps 1 to 5 </summary>

### 1. Enable two-factor authentication

It is strongly recommended using two-factor authentication. Here is the link of
[Configuring two-factor
authentication](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication).

### 2. Set ssh connection

With SSH keys, you can connect to GitHub without supplying your username and
personal access token at each visit. Please follow the instructions below. If
you like to know more, see [Connecting to GitHub with
SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

#### 2.1. Checking for existing SSH keys

Open a terminal and run the command below: 

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

Open a terminal and run the command below:

```bash
cd 
```
Now you are in your `HOME` directory. Run the command below:

```bash
git clone git@github.com:EcoExtreML/STEMMUS_SCOPE.git
```

Now a new GitHub folder `STEMMUS_SCOPE` is created in your `HOME` directory.

> In this command, we clone the repository using `ssh` option. As we set the ssh
connection in [**Step 2**](#2-set-ssh-connection), this command here does not
ask for our user name and password.

### 5. Collaborate using GitHub

To know about the most common Git commands, follow the guides
[here](https://hackmd.io/B4v6KwsBRzG-akLDF8e5pg).
</details>

## Development of the MATLAB source of STEMMUS_SCOPE model

To contribute to the STEMMUS_SCOPE model, you need access to the model source code that is stored in the repository [STEMMUS_SCOPE](https://github.com/EcoExtreML/STEMMUS_SCOPE). You also need a MATLAB license. MATLAB `2021a` is installed on
[Snellius]((https://servicedesk.surfsara.nl/wiki/display/WIKI/Snellius)) and [CRIB](https://crib.utwente.nl/), see [this instruction](https://pystemmusscope.readthedocs.io/en/latest/contributing_link.html#development-of-stemmus-scope-model).

## Create an executable file of STEMMUS_SCOPE

See the [exe readme](./exe/README.md).

## Follow MATLAB style guidelines

When you are introducing new changes to the codes, please follow the style introduced in [MATLAB Guidelines 2.0, Richard Johnson](http://cnl.sogang.ac.kr/cnlab/lectures/programming/matlab/Richard_Johnson-MatlabStyle2_book.pdf).

When you submit a pull request, the code is also [checked](https://github.com/EcoExtreML/STEMMUS_SCOPE/actions/workflows/lint.yml) by the [MISS_HIT](misshit.org/) linter and style checker. 
The status of `MISS_HIT` checks is shown below the pull request. The checks should be successful (green) before merging the pull request. 
MISS_HIT is configured in [`miss_hit.cfg`](./miss_hit.cfg).

### Installing MISS_HIT
It is best practice to install packages in environments. See the dropdown menu for instructions.
However, you can also continue below to install MISS_HIT without these steps.

<details><summary>Python environment / conda instructions</summary>

You need to have a valid python installation on your system.

Create an enviroment with `venv` or conda:

### **Venv**
```bash
python3 -m venv misshit # python on windows.
```
Activate this environment
```bash
source misshit/bin/activate
```

Or on Windows:
```pwsh
./misshit/Scripts/Activate.ps1
```

### **conda**
```bash
conda env create --name misshit
conda activate misshit
```

</details>

Install miss hit (optionally in the conda or venv environment) with:
```bash
pip install miss-hit
```

To run the style checker or linter, navigate to the STEMMUS_SCOPE repository, and run the following commands:

```
mh_style
mh_lint
```

For more information on installing and using MISS_HIT, look at [MISS_HIT's readme](https://github.com/florianschanda/miss_hit#installation-via-pip).