FROM ubuntu:artful-20171019

ENV ensembl-gene-db 0.2 

ENV DEBIAN_FRONTEND noninteractive

COPY db_query.py /

RUN apt-get update \
    && apt-get install -y \
    git \
    python-mysqldb \
    mysql-client-5.7 \
    mysql-server-5.7 \
    sudo \
    vim \
    wget \
    && adduser --disabled-password --gecos '' ubuntu && adduser ubuntu sudo && echo "ubuntu    ALL=(ALL)   NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu \
    && cd /root/ \
    && mkdir /var/run/mysqld \
    && chown mysql:mysql /var/run/mysqld \
    && echo "secure-file-priv = \"\"" >> /etc/mysql/mysql.conf.d/mysqld.cnf \
    && /usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql --daemonize \
    && mysql -e "create database hg38" \
    && cd /var/lib/mysql/hg38/ \
    && wget ftp://ftp.ensembl.org/pub/release-92/mysql/homo_sapiens_core_92_38/external_synonym.txt.gz \
    && wget ftp://ftp.ensembl.org/pub/release-92/mysql/homo_sapiens_core_92_38/gene.txt.gz \
    && wget ftp://ftp.ensembl.org/pub/release-92/mysql/homo_sapiens_core_92_38/gene_attrib.txt.gz \
    && wget ftp://ftp.ensembl.org/pub/release-92/mysql/homo_sapiens_core_92_38/homo_sapiens_core_92_38.sql.gz \
    && wget ftp://ftp.ensembl.org/pub/release-92/mysql/homo_sapiens_core_92_38/seq_region.txt.gz \
    && wget ftp://ftp.ensembl.org/pub/release-92/mysql/homo_sapiens_core_92_38/xref.txt.gz \
    && gunzip external_synonym.txt.gz \
    && gunzip gene.txt.gz \
    && gunzip gene_attrib.txt.gz \
    && gunzip homo_sapiens_core_92_38.sql.gz \
    && gunzip seq_region.txt.gz \
    && gunzip xref.txt.gz \
    && mv external_synonym.txt external_synonym.tsv \
    && mv gene.txt gene.tsv \
    && mv gene_attrib.txt gene_attrib.tsv \
    && mv seq_region.txt seq_region.tsv \
    && mv xref.txt xref.tsv \
    && cat homo_sapiens_core_92_38.sql | mysql --user=root --database=hg38 \ 
    && mysqlimport --user root hg38 external_synonym.tsv \
    && mysqlimport --user root hg38 gene.tsv \
    && mysqlimport --user root hg38 gene_attrib.tsv \
    && mysqlimport --user root hg38 seq_region.tsv \
    && mysqlimport --user root hg38 xref.tsv \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/mysql/hg38/*.sql /var/lib/mysql/hg38/*.tsv /var/lib/mysql/mirbase/*.sql /var/lib/mysql/mirbase/*.tsv \
    && mysqladmin shutdown \
    && cd /
