#!/bin/bash
sudo apt-get update
sudo apt install mysql-client -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get install -y python3.8 python3-pip python3.8-dev python3.8-venv python3.8-distutils net-tools gunicorn libmysqlclient-dev
mkdir -p /var/www/flask-app
cd /var/www/flask-app/
python3 -m venv venv
source venv/bin/activate
git clone https://github.com/rajneesh011/Flask-CRUD-App.git
cd Flask-CRUD-App/  
pip3 install -r requirements.txt
# export DATABASE_URL=mysql://${var.db_username}:${var.db_password}@$(terraform output -raw rds_endpoint)/${var.db_name}
export host=${tarraform output -raw rds_endpoint}
export user=${var.db_username}
export password=${var.db_password}
export database=${var.db_name}
gunicorn --bind 0.0.0.0:5000 app:app
