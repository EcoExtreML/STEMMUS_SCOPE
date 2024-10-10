#

> NOTE: The instructions below are meant for users who want to add changes to
the model source code. If you want to run the model, see the documentation on
`Running the model`.

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

## Adding changes to the model source code

To setup the required software and configurations, see the documentation on
`Getting started`.

It would be ideal to introduce changes incrementally over time. This way, you
can track the changes and understand the impact of each change. Here are the
steps to follow:

- Submit [an issue](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues) to the
  repository. This issue should describe the problem or the feature you want to
  introduce.
- Create a new branch from the `main` branch. This branch should have a
  descriptive name that relates to the issue you are working on.
- Make the changes in the new branch, for example, you can add new features, fix
  bugs, or improve the documentation. Follow [MATLAB Guidelines 2.0, Richard
  Johnson](http://cnl.sogang.ac.kr/cnlab/lectures/programming/matlab/Richard_Johnson-MatlabStyle2_book.pdf)
  when introducing new changes to the codes.
- Commit the changes to the new branch. Write a descriptive commit message that
  explains the changes you are introducing.
- Push the changes to the repository.
- Create a **draft** [pull
  request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
  to the `main` branch. This pull request should reference the issue you are
  working on.
- When you are done with the changes, run [the tests](#testing-new-changes) and
  [MISS_HIT commands](#miss_hit-checks), make sure they pass.
- Make the pull request ready for review. Ask for a review from the repository
  maintainers.
- The maintainers will review the changes and provide feedback. You may need to
  make additional changes based on the feedback.
- When the changes are approved, the maintainers will merge the pull request.

## Reviewing a pull request

When you are reviewing a pull request, you should follow the steps below:

- Check the changes introduced in the pull request. Make sure the changes are
  consistent with the issue description. Also, check for example variable names,
  function names, documentation, global variables, ..., to see if the changes
  are consistent with the [MATLAB Style Guidelines
  2.0](http://cnl.sogang.ac.kr/cnlab/lectures/programming/matlab/Richard_Johnson-MatlabStyle2_book.pdf).
- Run [the tests](#testing-new-changes) and [MISS_HIT commands](#miss_hit-checks) to make sure they pass.
- Provide feedback on the changes. You can ask questions, suggest improvements,
  or point out issues.
- When you are satisfied with the changes, approve the pull request. Ask a
  maintainer to [re-generate the executable
  file](#creating-an-executable-file-of-stemmus_scope) and merge the pull
  request.
- If the changes are related to BMI, you have to ask the maintainer to make a
  new release of the model. This way a new docker image will be created and the
  model will be available for the users.
- If the changes are related to the documentation, make sure that documentation
  page can be built successfully, see [Building the documentation
  locally](#building-the-documentation-locally).

## Merging a pull request

When you are merging a pull request, you should follow the steps below:

- Make sure the pull request is approved by at least one reviewer.
- Make sure all the items in the pull requests list are checked.

## Creating an executable file of STEMMUS_SCOPE

See the disumentation on [executable
file](https://github.com/EcoExtreML/STEMMUS_SCOPE/tree/main/run_model_on_snellius/exe).

## MISS_HIT Checks

When you submit a pull request, the code is also
[checked](https://github.com/EcoExtreML/STEMMUS_SCOPE/actions/workflows/lint.yml)
by the [MISS_HIT](https://misshit.org/) linter and style checker. The status of
`MISS_HIT` checks is shown below the pull request. The checks should be
successful (green) before merging the pull request. To work with `MISS_HIT`,
follow the instructions below:

- Installing MISS_HIT: To install MISS_HIT, follow their [installation
  instructions](https://github.com/florianschanda/miss_hit#installation-via-pip).

- Running MISS_HIT: To run the style checker or linter, navigate to the `src/`
  folder in STEMMUS_SCOPE, and run the following commands:

  ```bash
  mh_style
  mh_lint
  mh_metric
  ```

  Follow the errors and information in the output to fix any issues.

- Configuring MISS_HIT: `MISS_HIT` is configured in
[`miss_hit.cfg`](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/miss_hit.cfg).
This file contains the configuration for the linter and style checker. Please do
not change this file unless you are familiar with the configuration options.

## Testing new changes

To test the new changes, we can only check if the new changes do not break the
model. To do this, follow the steps below:

- Run the notebook `compare_git_branch_results.ipynb` in the `test` folder. This
  notebook will compare the results of the model between the `main` branch and
  the new branch with the changes. If the results are similar, the changes do
  not break the model.
- [Create the executable file](#creating-an-executable-file-of-stemmus_scope) of
  the model and run the model with the new changes. Check if the model runs
  without any errors.
- [Run the model with Octave](#octave-compatibility) to check if the new changes
  are compatible with Octave.

## Building the documentation locally

Documentation is created using several markdown files and the [`mkdocs`
tool](https://www.mkdocs.org/). The markdown files are located in the `docs`
folder. The configuration file for `mkdocs` is `mkdocs.yml` located in the root
directory. To build the documentation locally, follow the steps below:

- Install the required dependencies as:

  ```bash
  cd STEMMUS_SCOPE
  pip install -r docs/requirements.txt
  ```

- Build the documentation as:

  ```bash
  mkdocs build
  ```

- Preview the documentation as:

  ```bash
  mkdocs serve
  ```

Click on the link provided in the terminal to view the documentation in your
browser.

## Making a release

When you are ready to make a release of the model, follow the steps below:

- Make sure all new changes are added to changes log in the [`CHANGELOG.md`
  file](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/CHANGELOG.md).
- Create a new release in the repository. The release should have a version number
  following the [semantic versioning](https://semver.org/) guidelines.
- Add a description of the changes in the release notes.

## GitHub actions workflow

GitHub actions workflows are located in the folder `.github/workflows`:

- `lint.yml`: This workflow checks the code style and lints the code using
  `MISS_HIT`.
- `doc_deploy.yml`: This workflow builds the documentation and deploys it to
  GitHub pages.
- `publish-container`: This workflow builds the docker image and publishes it to
  the repository once a new release is made. The docker image will avialable in
  the
  [packages](https://github.com/EcoExtreML/STEMMUS_SCOPE/pkgs/container/stemmus_scope)
  in the repository.

## Docker image

The
[Dockerfile](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/Dockerfile)
is located in the root directory. This file is used to build the docker image of
the model by Github action `publish-container`, see [GitHub actions
workflow](#github-actions-workflow). To build and run the docker image locally,
follow the steps below:

- Install [Docker](https://www.docker.com/).
- Build the docker image as:

  ```bash
  cd STEMMUS_SCOPE
  docker build -t stemmus_scope .
  ```

- Run the docker image with the BMI interface as:

  ```bash
  docker run -u $(id -u):$(id -g) -v /path_to_input_folder:/path_to_input_folder -v /path_to_output_folder:/path_to_output_folder -it stemmus_scope
  ```

  With `-it` option, you can enter the docker interactive mode.
  Now, BMI asks you to select one of the steps "initialize", "update" or "finalize".
  To initialize the model using a config file, type:

  ```bash
  initialize "path/to/config_file_template.txt"
  ```

## Octave compatibility

See the documentation on [Octave compatibility](./Octave_instructions.md).
