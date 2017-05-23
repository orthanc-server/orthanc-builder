#!/usr/bin/env bash
# Installs unixODBC and the Microsoft ODBC driver for SQL Server
# Used by Dockerfile, but also intended as a stand-alone utility
# Copied from https://docs.microsoft.com/en-us/sql/connect/odbc/linux/installing-the-microsoft-odbc-driver-for-sql-server-on-linux

set -x # Trace execution
set -e # Stop on error

curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
ACCEPT_EULA=Y apt-get -y install msodbcsql=13.1.4.0-1 mssql-tools=14.0.3.0-1 unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc