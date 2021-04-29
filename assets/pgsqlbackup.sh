#!/bin/bash
# Simple script to backup postgresql databases

# Parent backup directory
backup_parent_dir="/var/backups/postgresql"

# PostgreSQL settings
pg_host="HOST"
pg_port="PORT"
pg_user="USER"
pg_password="PASSWD"


# Check MySQL password
# echo exit | mysql --user=${mysql_user} --password=${mysql_password} -B 2>/dev/null
# if [ "$?" -gt 0 ]; then
#   echo "MySQL ${mysql_user} password incorrect"
#   exit 1
# else
#   echo "MySQL ${mysql_user} password correct."
# fi

# Create backup directory and set permissions
backup_date=`date +%Y_%m_%d_%H_%M`
backup_dir="${backup_parent_dir}/${backup_date}"
echo "Backup directory: ${backup_dir}"
mkdir -p "${backup_dir}"
chmod 644 "${backup_dir}"

# Get postgresql databases
pgsql_databases=`psql "host=$pg_host port=$pg_port user=$pg_user password=$pg_password" -At -c "select datname from pg_database where not datistemplate and datallowconn;"`


# Backup and compress each database
for database in $pgsql_databases
do
  echo "Creating backup of \"${database}\" database"
  # mysqldump ${additional_mysqldump_params} --user=${mysql_user} --password=${mysql_password} ${database} | gzip > "${backup_dir}/${database}.sql.gz"
  # chmod 644 "${backup_dir}/${database}.sql.gz"
	set -o pipefail
	# if ! pg_dump -Fp -h "$pg_host" -U "$pg_user" "$database" | gzip > $backup_dir"/$database".sql.gz.in_progress; then
  # if ! pg_dump -Fp "host=$pg_host port=$pg_port user=$pg_user password=$pg_password" "$database" | gzip > $backup_dir"/$database".sql.gz.in_progress; then
  if ! pg_dump -Fp --dbname="postgresql://$pg_user:$pg_password@$pg_host:$pg_port/$database" | gzip > $backup_dir"/$database".sql.gz.in_progress; then
		echo "[!!ERROR!!] Failed to produce plain backup database $database" 1>&2
	else
		mv $backup_dir"/$database".sql.gz.in_progress $backup_dir"/$database".sql.gz
	fi
	set +o pipefail
done

# compress the folder
# tar -zcvf "${backup_dir}.tar.gz" "${backup_dir}"
# rm -rf "${backup_dir}"

# Rotate backups
# Delete files older than 30 days
find $backup_parent_dir/ -type f -mtime +60 -delete;
# Delete empty directories
find $backup_parent_dir/ -type d -empty -delete;
