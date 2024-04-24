sudo mkdir -p /usr/local/share/fonts/inconsolata-nerd-fonts

sudo curl -fLo "/usr/local/share/fonts/inconsolata-nerd-fonts/fonts.tar.xz" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Inconsolata.tar.xz
sudo tar -xJf /usr/local/share/fonts/inconsolata-nerd-fonts/fonts.tar.xz -C /usr/local/share/fonts/inconsolata-nerd-fonts/
sudo rm /usr/local/share/fonts/inconsolata-nerd-fonts/fonts.tar.xz

sudo chown -R root: /usr/local/share/fonts/inconsolata-nerd-fonts
sudo chmod 644 /usr/local/share/fonts/inconsolata-nerd-fonts/*
sudo restorecon -vFr /usr/local/share/fonts/inconsolata-nerd-fonts

sudo fc-cache -v
