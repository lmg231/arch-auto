#!/bin/bash
#This one is for virture machine
if timedatectl set-ntp true &> /dev/null;then
echo "set time done"
fi
fdisk /dev/sda <<EOF
g
n


+300M
n


+4G
n



w

EOF
fdisk -l /dev/sda
read -r -s -n1 -p "Is that ok? Press any key to continue,or CTRL+C to exit."
if mkfs.ext4 /dev/sda3;then 
if mount /dev/sda3 /mnt;then
echo "mount /mnt success"
fi
fi

mkdir -p /mnt/efi
if mkfs.fat -F32 /dev/sda1;then
if mount /dev/sda1 /mnt/efi;then
echo "mount /mnt/efi success"
fi
fi

if mkswap /dev/sda2;then
if swapon /dev/sda2;then
echo "Creat swap success"
fi
fi
lsblk
read -r -s -n1 -p "Is that ok? Press any key to continue,or CTRL+C to exit."
reflector --country China --age 120 --sort rate
head -20 /etc/pacman.d/mirrorlist
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
pacman -S --noconfirm networkmanager zsh openssh git curl wget neofetch dialog haveged 
systemctl enable NetworkManager sshd haveged
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
pacman -S --noconfirm $MICROCODE ntfs-3g os-prober grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

EOFARCH
