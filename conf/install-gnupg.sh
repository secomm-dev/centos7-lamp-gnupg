# Install needed depencencies
yum install -y wget make gcc perl pcre-devel bzip2 glibc-static ncurses-devel \
             gnutls gnutls-utils zlib-devel sqlite-devel gnupg2-smime
 
mkdir -p /var/src/gnupg22 && cd /var/src/gnupg22
 
# Download dependencies and gnupg
wget -c https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.28.tar.gz && \
wget -c https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.2.tar.gz && \
wget -c https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.1.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/npth/npth-1.5.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.5.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-1.1.0.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-1.11.1.tar.bz2 && \
 
# Unpack
tar -xzf libgpg-error-1.28.tar.gz && \
tar -xzf libgcrypt-1.8.2.tar.gz && \
tar -xjf libassuan-2.5.1.tar.bz2 && \
tar -xjf libksba-1.3.5.tar.bz2 && \
tar -xjf npth-1.5.tar.bz2 && \
tar -xjf pinentry-1.1.0.tar.bz2 && \
tar -xjf gpgme-1.11.1.tar.bz2 && \
tar -xjf gnupg-2.2.5.tar.bz2 && \
 
# Install dependencies
cd libgpg-error-1.28/ && ./configure && make && make install && cd ../ && \
cd libgcrypt-1.8.2 && ./configure && make && make install && cd ../ && \
cd libassuan-2.5.1 && ./configure && make && make install && cd ../ && \
cd libksba-1.3.5 && ./configure && make && make install && cd ../ && \
cd npth-1.5 && ./configure && make && make install && cd ../ && \
cd pinentry-1.1.0 && ./configure --enable-pinentry-curses --disable-pinentry-qt4 && \
make && make install && cd ../ && \
cd gpgme-1.11.1 && ./configure && make && make install && cd ../ && \
 
# Install GnuGPG statically linked to libraries!
cd gnupg-2.2.5 && ./configure && make && make install && \
echo "/usr/local/lib" > /etc/ld.so.conf.d/gpg2.conf && ldconfig -v && \
echo "Complete!!!"
