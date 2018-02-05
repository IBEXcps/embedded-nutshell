# Install necessary dependencies
sudo pacman -S --needed base-devel git wget yajl

# install package-query
cd /tmp
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si --noconfirm
cd ..

# install yaourt
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -i --noconfirm

# Check yaourt
yaourt --version
