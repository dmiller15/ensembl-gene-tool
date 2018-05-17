FROM ubuntu:artful-20171019

ENV ensembl-gene-db 0.1 

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
    git \
#    libdbd-mysql-perl \
#    libdbi-perl \
    python-mysqldb \
    mysql-client-5.7 \
    mysql-server-5.7 \
#    r-base-core \
    sudo \
    vim \
    wget \
    && adduser --disabled-password --gecos '' ubuntu && adduser ubuntu sudo && echo "ubuntu    ALL=(ALL)   NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu \
#    && cd /usr/ \
#    && git clone -b cwl https://github.com/NCI-GDC/mirna.git \
#    && echo "hg38\tlocalhost\troot\t" >> /usr/mirna/v0.2.7/config/db_connections.cfg \
#    && echo "mirbase\tlocalhost\troot\t" >> /usr/mirna/v0.2.7/config/db_connections.cfg \
#    && chown -R ubuntu.ubuntu /usr/mirna \
    && cd /root/ \
    && mkdir /var/run/mysqld \
    && chown mysql:mysql /var/run/mysqld \
    && echo "secure-file-priv = \"\"" >> /etc/mysql/mysql.conf.d/mysqld.cnf \
    && /usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql --daemonize \
    && mysql -e "create database hg38" \
    && cd /var/lib/mysql/hg38/ \
    && wget ftp://ftp.ensembl.org/pub/release-92/mysql/homo_sapiens_core_92_38/gene.txt.gz \
    && wget ftp://ftp.ensembl.org/pub/release-92/mysql/homo_sapiens_core_92_38/homo_sapiens_core_92_38.sql.gz \
    && gunzip gene.txt.gz \
    && gunzip homo_sapiens_core_92_38.sql.gz \
    && mv gene.txt gene.tsv \
    && cat homo_sapiens_core_92_38.sql | mysql --user=root --database=hg38 \ 
    && mysqlimport --user root hg38 gene.tsv \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/mysql/hg38/*.sql /var/lib/mysql/hg38/*.tsv /var/lib/mysql/mirbase/*.sql /var/lib/mysql/mirbase/*.tsv \
    && mysqladmin shutdown \
    && cd /

COPY db_query.py /

RUN ["chmod 1777 /tmp", "&& sudo /usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql --daemonize", "python", "db_query.py"]
