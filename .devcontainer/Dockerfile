FROM gnuoctave/octave:8.1.0

# NOTE: all package version are pinned to avoid the container breaking with the 
#     latest version on octave's forge.
#
# IO is a dependency of statistics, needs to be installed first.
RUN octave --eval 'pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/io-2.6.4.tar.gz"'
RUN octave --eval 'pkg install "https://octave.sourceforge.io/download.php?package=statistics-1.4.3.tar.gz"'

# Install netcdf dependencies first.
RUN apt update && apt install -yq libnetcdf-dev
RUN octave --eval 'pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/netcdf-1.0.16.tar.gz"'

ARG USERNAME=octave
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME