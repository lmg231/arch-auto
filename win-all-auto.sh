#!/bin/bash
# This one is only for my computer
if timedatectl set-ntp true &> /dev/null;then
echo "set time done"
fi
fdisk /dev/nvme0n1 >> /dev/null <<EOF
n



w

EOF
fdisk -l /dev/nvme0n1
partprobe
read -r -s -n1 -p "Is that ok? Press any key to continue,or CTRL+C to exit."
if mkfs.ext4 /dev/nvme0n1p4;then 
if mount /dev/nvme0n1p4 /mnt;then
echo "mount /mnt success"
fi
fi

mkdir -p /mnt/efi
if mount /dev/nvme0n1p1 /mnt/efi;then
echo "mount /efi success"
fi

lsblk
sed -i "1i\Server = http://mirrors.163.com/archlinux/\$repo/os/\$arch" /etc/pacman.d/mirrorlist
read -r -s -n1 -p "Is that ok? Press any key to continue,or CTRL+C to exit."
pacstrap /mnt base base-devel linux linux-firmware man-db man-pages vi vim texinfo dhcpcd
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt <<EOFARCH
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo arch > /etc/hostname
echo -e "127.0.0.1    localhost\n::1    localhost\n127.0.0.1      arch.localdomain    arch" >> /etc/hosts
pacman -S --noconfirm networkmanager zsh openssh git curl wget neofetch dialog 
systemctl enable NetworkManager sshd
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman -Sy --noconfirm archlinux-keyring
pacman -Syu
passwd<<EOF
lxx000
lxx000
EOF
useradd -m -G wheel -s /bin/zsh lmg
passwd lmg<<EOF
lxx000
lxx000
EOF
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD/%wheel ALL=(ALL) NOPASSWD/' /etc/sudoers
pacman -S --noconfirm amd-ucode ntfs-3g os-prober grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg
EOFARCH
