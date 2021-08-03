FROM debian:buster-slim

# labels
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/archont94/counter-strike1.6"

# define default env variables
ARG SERVER_NAME="Counter-Strike 1.6 DockerServer"
ARG FAST_DL="http://127.0.0.1/cstrike/"
ARG ADMIN_STEAM_ID="STEAM_0:0:123456"

ENV PORT=27015
ENV MAP=de_dust2
ENV MAXPLAYERS=16
ENV SV_LAN=0

# install dependencies
RUN dpkg --add-architecture i386; \
    apt-get update; \
    apt-get -qqy install lib32gcc1 curl nginx nano; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*


# create directories, download steamcmd and install CS 1.6 via steamcmd
#     additional info: https://danielgibbs.co.uk/2017/10/hlds-steamcmd-workaround-appid-90-part-ii/
RUN mkdir /root/Steam /root/.steam ; \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxf - -C /root/Steam ; \
    /root/Steam/steamcmd.sh +login anonymous +force_install_dir "/hlds" +app_update 90 +app_set_config 90 mod cstrike validate +quit ; \
    rm -r /hlds/steamapps/* ; \
    curl -s https://raw.githubusercontent.com/dgibbs64/HLDS-appmanifest/master/CounterStrike/appmanifest_90.acf -o /hlds/steamapps/appmanifest_90.acf ; \
    /root/Steam/steamcmd.sh +login anonymous +force_install_dir "/hlds" +app_update 90 +app_set_config 90 mod cstrike validate +quit ; \
    rm -r /root/.steam /root/Steam

# install metamod
RUN mkdir -p /hlds/cstrike/addons/metamod/dlls ; \
    curl -sqL "http://prdownloads.sourceforge.net/metamod/metamod-1.20-linux.tar.gz" | tar zxf - -C /hlds/cstrike/addons/metamod/dlls ; \
    touch /hlds/cstrike/addons/metamod/plugins.ini ; \
    sed -i 's/gamedll_linux "dlls\/cs.so"/#gamedll_linux "dlls\/cs.so"\ngamedll_linux "addons\/metamod\/dlls\/metamod.so"/'  /hlds/cstrike/liblist.gam

# install amxmodx
RUN curl -sqL "https://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz" | tar zxf - -C /hlds/cstrike ; \
    curl -sqL "https://www.amxmodx.org/release/amxmodx-1.8.2-cstrike-linux.tar.gz" | tar zxf - -C /hlds/cstrike ; \
    echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> /hlds/cstrike/addons/metamod/plugins.ini ; \
    echo "\"$ADMIN_STEAM_ID\" \"\" \"abcdefghijklmnopqrstu\" \"ce\" ; Server admin added during container build" >> /hlds/cstrike/addons/amxmodx/configs/users.ini

# configure nginx to allow for FastDownload
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup ; \
    bash -c "mkdir -p /srv/cstrike/{gfx,maps,models,overviews,sound,sprites}/nothing-here"
COPY nginx_config.conf /etc/nginx/sites-available/default

# configure FastDownload
RUN echo "// enable fast download - sv_downloadurl have to start with 'http', end with 'cstrike/', i.e. 'http://10.20.30.40/cstrike/'  " >> /hlds/cstrike/server.cfg ; \
    echo "sv_downloadurl \"$FAST_DL\"" >> /hlds/cstrike/server.cfg ; \
    echo "sv_allowdownload 1" >> /hlds/cstrike/server.cfg ; \
    echo "sv_allowupload 1" >> /hlds/cstrike/server.cfg

# change server name
RUN sed -i "s/hostname \"Counter-Strike 1.6 Server\"/hostname \"$SERVER_NAME\"/" /hlds/cstrike/server.cfg

# start server
WORKDIR /hlds
ENTRYPOINT service nginx start; ./hlds_run -game cstrike -strictportbind -ip 0.0.0.0 -port $PORT +sv_lan $SV_LAN +map $MAP -maxplayers $MAXPLAYERS
