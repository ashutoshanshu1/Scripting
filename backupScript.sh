#!/usr/bin/sh
backup_dir="/home/kali/Desktop/scripting"
backup_file="backup_$(date +"%Y-%m-%d_%H-%M-%S").tar.gz"

files_to_backup=""
compression="yes"
retain_days=7

# user manual
usage() {
    echo "Usage: $0 [OPTIONS] [FILES...]"
    echo "./backup_script.sh -d /path/to/backup -n my_backup.tar.gz /path/to/directory1 /path/to/directory2"
    echo "Options:"
    echo "  -d, --directory DIR     Specify backup directory (default: /path/to/backup)"
    echo "  -n, --name NAME         Specify backup file name (default: backup_YYYY-MM-DD_HH-MM-SS.tar.gz)"
    echo "  -c, --compress          Enable compression (default: yes)"
    echo "  -r, --retain DAYS       Number of days to retain backups (default: 7)"
    echo "  -h, --help              Display this help message"
    exit 1
}

while [ $# -gt 0 ]; do
    case $1 in
        -d | --directory)
            backup_dir="$2"
            shift 2
            ;;
        -n | --name)
            backup_file="$2"
            shift 2
            ;;
        -c | --compress)
            compression="yes"
            shift
            ;;
        -r | --retain)
            retain_days="$2"
            shift 2
            ;;
        -h | --help)
            usage
            ;;
        *)
            files_to_backup="$files_to_backup $1"
            shift
            ;;
    esac
done

#	CHECK THE DIRECTORY, IF NOT AVAILABLE, CREATE ONE
if [ ! -d "$backup_dir" ]
then
	mkdir -p $backup_dir
fi

# Backup files/directories
echo "Backing up: $files_to_backup"
if [ "$compression" == "yes" ]; then
    tar -czf "$backup_dir/$backup_file" $files_to_backup
else
    tar -cf "$backup_dir/$backup_file" $files_to_backup
fi
echo "Backup saved to: $backup_dir/$backup_file"


exit 0
