# Counter-Strike 1.6 Docker Server
Docker Image for a dedicated Counter-Strike 1.6 server with metamod, amxmodx and fast download.



## Quick start

The fastest way to set this up is to pull the image and start it via `docker run`.

``` bash
docker pull archont94/counter-strike1.6
```

``` bash
docker run --name cs16-server -p 27015:27015/udp -p 27015:27015 -p 80:80 archont94/counter-strike1.6:latest
```

However it's recommend to run the server via `docker-compose`. You can find an example docker-compose.yml below.
Port 27015 is required by Counter-Strike 1.6 server.
Port 80 is used to serve assets (maps, gfxs) via http for fast download feature. 


## Available build variables

| Variable       | Value                             | Comment |
| -------------- | --------------------------------- | ------- |
| SERVER_NAME    | "Counter-Strike 1.6 DockerServer" | Custom name for server, can be edited later in /hlds/cstrike/server.cfg |
| FAST_DL        | "http://127.0.0.1/cstrike/"       | Full address for fast download site, can be edited later in /hlds/cstrike/server.cfg |
| ADMIN_STEAM_ID | "STEAM_0:0:123456"                | Custom SteamID for admin user, can be checked in Counter-Strike console (type 'status' when you are connected to any server). Can be edited in /hlds/cstrike/addons/amxmodx/configs/users.ini |

In order to edit file, log inside container with 'docker exec -it CONTAINER_ID bash'. After that you can run nano editor and modify files.

## Available environment variables

| Variable   | Value    |
| ---------- | -------- |
| PORT       | 27015    |
| MAP        | de_dust2 |
| MAXPLAYERS | 16       |
| SV_LAN     | 0        |

## Custom config files

You can add you own `server.cfg`, `banned.cfg`, `listip.cfg` and `mapcycle.txt` (or any other file) by linking them as volumes into the image.

``` bash
-v /path/to/your/server.cfg:/hlds/cstrike/server.cfg
```

The complete command looks like this:

``` bash
docker run --name counter-strike1.6 -p 27015:27015/udp -p 27015:27015 -v /path/to/your/server.cfg:/hlds/cstrike/server.cfg archont94/counter-strike1.6:latest
```

Keep in mind the server.cfg file can override the settings from your environment variables:  
`MAP`, `MAXPLAYERS` and `SV_LAN`


## Docker Compose

Create a `docker-compose.yml` file and start the server via `docker-compose up -d`.

### Example docker-compose.yml

``` yml
version: '3'

services:

  hlds:
    container_name: counter-strike1.6
    image: archont94/counter-strike1.6:latest
    restart: always
    environment:
      - PORT=27015
      - MAP=de_dust2
      - MAXPLAYERS=16
      - SV_LAN=0
    ports:
      - 27015:27015/udp
      - 27015:27015
    volumes:
      - /path/to/your/banned.cfg:/hlds/cstrike/banned.cfg
      - /path/to/your/listip.cfg:/hlds/cstrike/listip.cfg
      - /path/to/your/server.cfg:/hlds/cstrike/server.cfg
      - /path/to/your/mapcycle.txt:/hlds/cstrike/mapcycle.txt
```
