## 1 测试网络连接

```
dhcpcd
ping www.baidu.com
```
## 2 更新系统时间
```
timedatectl set-ntp true
```
## 3 查看分区情况
```
fdisk -l
```
## 4 创建根分区
```
fdisk /dev/sda
n 
w 
```
## 5 格式化刚刚的分区
```
mkfs.ext4 /dev/sda4
```
## 6 挂载分区
```
mount /dev/sda4 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1/ /mnt/boot/efi
```
## 7 选择镜像
```
vim /etc/pacman.d/mirrorlist
/tuna enter dd gg shift+P
/ustc ，/163
：wq
pacman -Syy
```
## 8 安装基本包
```
pacstrap /mnt base base-devel linux linux-firmware man-db man-pages vi vim  texinfo dhcpcd
```
## 9 把挂载信息写入fstab文件
```
genfstab -U /mnt >> /mnt/etc/fstab
vim /mnt/etc/fstab
//efi行的2改成0
```
## 10 操作权移交
```
arch-chroot /mnt
```
## 11 设置时区
```
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
date
```
## 12 本地化
```
vim /etc/locale.gen   
//去除en_US.UTF-8，zh_CN.UTF-8，zh_CN.GBK的注释
locale-gen
vim /etc/locale.conf  
//添加 LANG=en_US.UTF-8
```
## 13 设置主机名
```
vim /etc/hostname
vim /etc/hosts
    127.0.0.1	localhost
    ::1		localhost
    127.0.1.1	hostname.localdomain  hostname
```
## 14 设置root密码
```
passwd
```
## 15 配置开机联网
```
pacman -S networkmanager
systemctl enable dhcpcd
systemctl enable NetworkManager
```
## 16 安装引导
```
pacman -S amd-ucode ntfs-3g os-prober grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
```
## 17 卸载重启
```
umount -R /mnt/boot/efi
umount /mnt
reboot
```
## 18 安装aur
```shell
vim /etc/pacman.conf
#[multilib]去掉注释，增加
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
#color 取消注释
pacman -Syy
pacman -S archlinuxcn-keyring
pacman -S yay
```
## 19 安装xorg
```
pacman -S xorg-server
pacman -S alsa-utils pulseaudio pulseaudio-alsa
```
## 20 安装驱动
```
pacman -S  nvidia nvidia-settings
```
## 21 安装显示管理器
```
pacman -S sddm sddm-kcm
systemctl enable sddm
yaourt sddm-theme-kde-plasma-chili  //主题
pacman -S base-devel   //开发环境
pacman -S openssh
systemctl start sshd
```
## 22 安装kde桌面
```
pacman -S plasma-desktop
pacman -S plasma-nm   //系统托盘网络管理工具
pacman -S kdebase  //基本软件
pacman -S arc-kde papirus-icon-theme latte-dock google-chrome   //主题 图标 dock栏 浏览器

```
## 23安装中文字体
```
pacman -S ttf-dejavu ttf-liberation wqy-microhei ttf-fira-code
```
## 24 创建普通用户
```
useradd -m -g users -G wheel -s /bin/bash 用户名
passwd 用户名
visudo
/wheel ALL=   //取消注释
```
## 25 首次用户目录生成
```
pacman -S xdg-user-dirs
xdg-user-dirs-update
```
