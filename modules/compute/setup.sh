#!/bin/bash

exec > /var/log/setup.log 2>&1
set -x

dnf update -y
dnf install -y python3-pip mariadb105

export DB_PASSWORD=$(aws ssm get-parameter --name "/prod/web-app/db_password" --with-decryption --query "Parameter.Value" --output text --region eu-west-1)

mkdir -p /var/www/webapp/templates
cd /var/www/webapp || exit 1

cat <<'EOF' > /var/www/webapp/templates/index.html
${html_content}
EOF

cat <<'EOF' > /var/www/webapp/app.py
${python_content}
EOF

cat <<'EOF' > /var/www/webapp/schema.sql
${sql_content}
EOF

pip3 install flask gunicorn pymysql

export DB_HOST="${db_host}"
export DB_USER="${db_user}"
export DB_NAME="${db_name}"

echo "DB_HOST=$DB_HOST" >> /var/log/setup.log
echo "DB_USER=$DB_USER" >> /var/log/setup.log
echo "DB_NAME=$DB_NAME" >> /var/log/setup.log

until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "Aspetto che RDS sia pronto..."
  sleep 10
done

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < /var/www/webapp/schema.sql

nohup env DB_HOST="$DB_HOST" DB_USER="$DB_USER" DB_PASSWORD="$DB_PASSWORD" DB_NAME="$DB_NAME" \
gunicorn -w 2 -b 0.0.0.0:80 app:app > /var/log/gunicorn.log 2>&1 &