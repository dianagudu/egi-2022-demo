FROM debian:bullseye as ssh_oidc_ldap

##### install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    ssh \
    python3 \
    python3-pip \
    libcurl4 \
    curl \
    gnupg2 \
    libnss-ldapd \
    libpam-ldapd \
    vim
RUN echo deb https://repo.data.kit.edu/debian/stable ./ >> /etc/apt/sources.list
RUN curl repo.data.kit.edu/key.pgp > /etc/apt/trusted.gpg.d/kit-repo.gpg
# RUN apt-key adv --keyserver hkp://pgp.surfnet.nl \
#     --recv-keys ACDFB08FDC962044D87FF00B512839863D487A87
RUN apt-get update && apt-get install -y \
    pam-ssh-oidc\
    && rm -rf /var/lib/apt/lists/*

##### pam config
COPY pam-ssh-oidc-config.ini /etc/pam.d/pam-ssh-oidc-config.ini
RUN echo "auth   sufficient pam_oidc_token.so config=/etc/pam.d/pam-ssh-oidc-config.ini\n$(cat /etc/pam.d/sshd)" > /etc/pam.d/sshd
RUN echo "session    required   pam_mkhomedir.so skel=/etc/skel umask=0077\n" >> /etc/pam.d/sshd

##### ssh config
RUN mkdir /run/sshd
RUN echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication yes" > /etc/ssh/sshd_config.d/oidc.conf

##### motley-cue config
RUN pip3 install motley-cue
RUN mkdir /etc/motley_cue /var/log/motley_cue /run/motley_cue /var/lib/motley_cue\
    && ln -s /config_files/motley_cue.conf /etc/motley_cue/motley_cue.conf \
    && ln -s /config_files/feudal_adapter.conf /etc/motley_cue/feudal_adapter.conf \
    && ln -s  /config_files/templates /etc/motley_cue/templates
ENV PYTHONUNBUFFERED 1
ENV FEUDAL_ADAPTER_CONFIG=/etc/motley_cue/feudal_adapter.conf
# fix long tokens issue
RUN sed -i 's/header.lstrip("Bearer ")/header.lstrip("Bearer").lstrip()/g'  /usr/local/lib/python3.9/dist-packages/motley_cue/mapper/token_manager.py

#### LDAP client config
COPY nslcd.conf /etc/nslcd.conf
COPY nsswitch.conf /etc/nsswitch.conf
RUN chown nslcd:nslcd /etc/nslcd.conf && chmod 0600 /etc/nslcd.conf

##### expose needed ports
EXPOSE 22

##### init cmd and entrypoint
COPY ./runner.sh /srv/runner.sh
COPY ./entrypoint.sh /srv/entrypoint.sh
RUN chmod +x /srv/runner.sh /srv/entrypoint.sh

ENTRYPOINT [ "/srv/entrypoint.sh" ]
CMD ["/srv/runner.sh"]


FROM nginx:alpine as nginx_motley_cue
RUN rm /etc/nginx/conf.d/default.conf \
    && ln -s /config_files/nginx.motley_cue /etc/nginx/conf.d/default.conf
EXPOSE 8080

