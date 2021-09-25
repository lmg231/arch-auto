#!/bin/bash
if timedatectl set-ntp true &> /dev/null;then
timedatectl status
fi
selectPart() {
    lsblk
    while true; do
        lsblk -nld | awk '{if($3==1) print(NR,$1,"Warning: Removable Disk!");else print(NR,$1)}'
        read -rp "Choose the serial number of the disk:" NUM1
        DISKNAME=$(lsblk -nld | awk '{if(NR == '"$NUM1"') print($1)}')
        DISKPATH=/dev/$DISKNAME
        if lsblk -f "$DISKPATH"; then
            read -rp "Enter y to enter partition mode,other to skip:" BOOLEAN1
            if [ "$BOOLEAN1" == "y" ]; then
                fdisk "$DISKPATH"
            fi
            break
        else
            echo "You enter a wrong number,please try again!"
        fi
    done

    while true; do
        read -rp "Enter the serial number of the partition:" NUM2
        PARTNAME=$(lsblk -nl "$DISKPATH" | awk '/'"$DISKNAME"'.?'"$NUM2"'/ {print($1)}')
        PARTPATH=/dev/$PARTNAME
        if lsblk -f "$PARTPATH"; then
            break
        else
            echo "You enter a wrong number,please try again!"
        fi
    done

    read -rp "Enter y to format a partition:" BOOLEAN2
    if [ "$BOOLEAN2" == "y" ]; then
        echo -e "Choose a formatting method: \n1: ext4    2: xfs    3: btrfs(Is said to be friendly to ssd)    4:fat32(for ESP only)    5:swap"
        while true; do
            read -rp "Choose one to continue:" METHOD
            case $METHOD in
            1)
                mkfs.ext4 "$PARTPATH"
                break
                ;;
            2)
                mkfs.xfs "$PARTPATH"
                break
                ;;
            3)
                mkfs.btrfs "$PARTPATH"
                SUPPORT="btrfs-progs"
                break
                ;;
            4)
                mkfs.fat -F32 "$PARTPATH"
                break
                ;;
            5)
                mkswap "$PARTPATH"
                swapon "$PARTPATH"
                break
                ;;
            *)
                echo "You input a wrong number,please try again or press CTRL+C to exit"
                ;;
            esac
        done
    fi
}

mountPartition() {
    if [ $# == 1 ]; then
        mountPoint=$1
 
          selectPart
    elif [ $# == 2 ]; then
        mountPoint=$2
        PARTPATH=$1
    fi
    if mount "$PARTPATH" "$mountPoint"; then
        echo "Mount to $mountPoint success."
        lsblk
    else
        echo "Mount failed,please try again later by yourself and run this script bypass this step."
    fi
}

if ls /sys/firmware/efi/efivars &> /dev/null; then
    echo "Your computer boot in uefi mode,GPT lable and an efi partition are needed"
else
    exit 0
fi
#Menu
PS3="1:mnt 2:EFI 3:SWAP 4:Another 5:EXIt  Please select:"
select option in "Mount /mnt" "Mount efi" "Creat a swap partition" "Creat an another partition" "Exit Menu"; do
    case $option in
    "Exit Menu")
        break
        ;;
    "Mount /mnt")
        mountPartition /mnt
        ;;
    "Mount efi")
        read -rp "Please create a EFI mount point:/efi,/boot/efi,or /boot:" ESP
        mkdir -p "/mnt$ESP"
        fdisk -l | awk '/EFI/ {print $1}'
        read -rp "Whether there is an EFI partion?:number or no:" BOOLEAN3
        if [ "$BOOLEAN3" == "no" ]; then
            mountPartition "/mnt$ESP"
        else
            EPATION=$(fdisk -l | awk '/EFI/ {print $1}' | awk 'NR=='"$BOOLEAN3"' {print $1}')
            mountPartition "$EPATION" "$ESP"
        fi
        ;;
    "Creat a swap partition")
        selectPart
        ;;
    "Creat an another partition")
        read -rp "Creat a moint point such as /mnt/home:" ANOPART
        mkdir -p "/mnt$ANOPART"
        mountPartition "$ANOPART"
        ;;
    *)
        echo "sorry,wrong selection"
        ;;
    esac
done
lsblk
if [ -z "$ESP" ]; then
    read -rp "Input the ESP mount point again:" ESP
fi
read -r -s -n1 -p "Is that ok? Press any key to continue,or CTRL+C to exit."
echo ""
read -rp "Give your computer a name:" CNAME
read -rp "Input your root password:" ROOTPASSWORD
read -rp "Input your name:" USERNAME
read -rp "Input  your password:" USERPASSWORD
read -rp "Input the boot name:" BOOTNAME
while true; do
    read -rp "Select your cpu manufacturer:1 intel    2 amd:" CPU
    if [ "$CPU" == 1 ]; then
        MICROCODE="intel-ucode"
        break
    elif [ "$CPU" == 2 ]; then
        MICROCODE="amd-ucode"
        break
    else
        echo "Wrong,please again!"
    fi
done
sed -i "1i\Server = http://mirrors.163.com/archlinux/\$repo/os/\$arch" /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel linux linux-firmware man-db man-pages vi vim texinfo dhcpcd $SUPPORT
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt <<EOFARCH
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
sed -i 's/^#zh_TW.UTF-8/zh_TW.UTF-8/' /etc/locale.gen
sed -i 's/^#ja_JP.UTF-8/ja_JP.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo $CNAME > /etc/hostname
echo -e "127.0.0.1    localhost\n::1    localhost\n127.0.0.1      $CNAME.localdomain    $CNAME" >> /etc/hosts
pacman -S --noconfirm networkmanager zsh openssh git curl wget neofetch dialog haveged
systemctl enable NetworkManager sshd haveged
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman -Sy --noconfirm archlinux-keyring
pacman -Syu
passwd<<EOF
$ROOTPASSWORD
$ROOTPASSWORD
EOF
useradd -m -G wheel -s /bin/zsh $USERNAME
passwd $USERNAME<<EOF
$USERPASSWORD
$USERPASSWORD
EOF
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD/%wheel ALL=(ALL) NOPASSWD/' /etc/sudoers
pacman -S --noconfirm $MICROCODE ntfs-3g os-prober grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=$ESP --bootloader-id=$BOOTNAME
grub-mkconfig -o /boot/grub/grub.cfg
EOFARCH
