## 1 显示管理器

```shell
pacman -S xorg（wayland）
```

## 2 桌面登陆器

```shell
pacman -S gdm sddm
systemctl enable gdm （sddm）
systemctl start gdm（sddm）
```

## 3 显卡驱动

![](C:\Users\lmg23\Pictures\Saved Pictures\显卡.png)

## 4 桌面环境

```shell
pacman -S gnome（plasma）
```

## 5 中文社区源

```shell
echo -e "[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" >> /etc/pacman.conf
pacman -Sy --noconfirm archlinuxcn-keyring
pacman -S yay
```

## 6 设置git代理

```shell
export all_proxy=socks5://192.168.0.103:10808
```

## 7 安装字体 

```shell
pacman -S ttf-dejavu ttf-consolas-with-yahei nerd-fonts-meslo
```

## 8 输入法

```shell
#gnome下用ibus
sudo pacman -S ibus ibus-qt ibus-rime
#kde下用fcitx5
sudo pacman -S $(pacman -Ssq fcitx5)
echo -e "INPUT_METHOD  DEFAULT=fcitx5\nGTK_IM_MODULE DEFAULT=fcitx5\nQT_IM_MODULE  DEFAULT=fcitx5\nXMODIFIERS    DEFAULT=\@im=fcitx5" >> ~/.pam_environment
```

## 9 相关美化

```shell
#for gnome：
yay -S adapta-gtk-theme  papirus-icon-theme numix-circle-icon-theme-git gnome-tweak-tool  gnome-shell-extensions chrome-gnome-shell ocs-url 
curl -L -O http://archibold.io/sh/archibold
sudo chmod +x archibold
./archibold login-backgroung 你的背景的地址
#for kde：
yay -S kcm-colorful-git breeze-blurred-git ocs-url
#for ohmyzsh:
yay -S oh-my-zsh-git zsh-syntax-highlighting zsh-autosuggestions
cp /usr/share/oh-my-zsh/zshrc ~/.zshrc
sudo ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting /usr/share/oh-my-zsh/custom/plugins/
sudo ln -s /usr/share/zsh/plugins/zsh-autosuggestions /usr/share/oh-my-zsh/custom/plugins/
yay -S --noconfirm zsh-theme-powerlevel10k-git
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

