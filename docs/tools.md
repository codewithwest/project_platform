# Useful DevOps Tools

## K9s

- makes Kubernetes management more accessible and less daunting, especially for those who are not Kubernetes experts.

- k9s is a command-line tool that makes it easy to manage Kubernetes clusters.

#### **Note**: check for latest version on https://github.com/derailed/k9s

Download the .deb file

```sh
 wget https://github.com/derailed/k9s/releases/download/v0.50.9/k9s_linux_amd64.deb
```

install the .deb file

```sh
sudo apt install ./k9s_linux_amd64.deb
```
## Kubectl

```sh
sudo snap install kubectl
```

## Kubectx

- kubectx is a tool that helps you switch between contexts (clusters) on kubectl faster.

- kubens is a tool to switch between Kubernetes namespaces (and configure them for kubectl) easily.

```sh
sudo apt install kubectx
```

## kubescape

Kubescape can scan clusters, YAML files, and Helm charts and detects the misconfigurations according to multiple sources.

```sh
curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash.
```

## Lazydocker

Lazydocker is a command-line tool that makes it easier to manage docker containers.

```sh
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
```

## zsh

Zsh is a shell that provides a more feature-rich command line for interactive use.

```sh
sudo apt install zsh -y
```

### Set zsh as default shell

```sh
chsh -s $(which zsh)
```

### Logout and Login to apply changes

```sh
echo $SHELL
/usr/bin/zsh
```

### Install oh-my-zsh

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### install fonts-powerline

```sh
sudo apt install fonts-powerline
```

### install powerlevel10k

```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Edit .zshrc file set theme to powerlevel10k

```sh
echo 'source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme"' >>~/.zshrc
```

### Restart zsh

```sh
source ~/.zshrc
```

### Install Dracula theme for GNOME terminal

```sh
sudo apt-get install dconf-cli

    git clone https://github.com/dracula/gnome-terminal.git
    cd gnome-terminal
    ./install.sh

```

### Install plugins (zsh-autosuggestions and zsh-syntax-highlighting)

- Download zsh-autosuggestions :

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

- Download zsh-syntax-higlighting :

```sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

Edit ~/.zshrc file, find plugins=(git) replace plugins=(git) with :

```sh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

Reopen your terminal, now you should be able to use the auto suggestions and syntax highlighting.
