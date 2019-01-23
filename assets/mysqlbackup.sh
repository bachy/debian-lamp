#!/bin/bash
# Simple script to backup MySQL databases

# Parent backup directory
backup_parent_dir="/var/backups/mysql"

# MySQL settings
mysql_user="root"
mysql_password="ROOTPASSWD"

# Read MySQL password from stdin if empty
# if [ -z "${mysql_password}" ]; then
#   echo -n "Enter MySQL ${mysql_user} password: "
#   read -s mysql_password
#   echo
# fi

# Check MySQL password
echo exit | mysql --user=${mysql_user} --password=${mysql_password} -B 2>/dev/null
if [ "$?" -gt 0 ]; then
  echo "MySQL ${mysql_user} password incorrect"
  exit 1
else
  echo "MySQL ${mysql_user} password correct."
fi

# Create backup directory and set permissions
backup_date=`date +%Y_%m_%d_%H_%M`
backup_dir="${backup_parent_dir}/${backup_date}"
echo "Backup directory: ${backup_dir}"
mkdir -p "${backup_dir}"
chmod 644 "${backup_dir}"

# Get MySQL databases
mysql_databases=`echo 'show databases' | mysql --user=${mysql_user} --password=${mysql_password} -B | sed /^Database$/d`

# Backup and compress each database
for database in $mysql_databases
do
  if [ "${database}" == "information_schema" ] || [ "${database}" == "performance_schema" ]; then
        additional_mysqldump_params="--skip-lock-tables --compact --no-autocommit "
  else
        additional_mysqldump_params=""
  fi
  echo "Creating backup of \"${database}\" database"
  mysqldump ${additional_mysqldump_params} --user=${mysql_user} --password=${mysql_password} ${database} | gzip > "${backup_dir}/${database}.sql.gz"
  chmod 644 "${backup_dir}/${database}.sql.gz"
done

# compress the folder
# tar -zcvf "${backup_dir}.tar.gz" "${backup_dir}"
# rm -rf "${backup_dir}"

# Rotate backups
# Delete files older than 30 days
find $backup_parent_dir/ -type f -mtime +60 -delete;
# Delete empty directories
find $backup_parent_dir/ -type d -empty -delete;
