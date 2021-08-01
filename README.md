# Counter-Strike 1.6 Docker Server
Docker Image for a dedicated Counter-Strike 1.6 server with metamod, amxmodx and fast download.



## Usage

The fastest way to set this up is to pull the image and start it via `docker run`.

``` bash
docker pull archont94/counter-strike1.6
```

``` bash
docker run --name cs16-server -p 27015:27015/udp -p 27015:27015 -p 80:80 archont94/counter-strike1.6:latest
```

Port 27015 is required by Counter-Strike 1.6 game server.

Port 80 is used to serve assets (maps, gfxs etc.) via http for fast download feature. 


## Available build variables

| Variable       | Value                             | Comment |
| -------------- | --------------------------------- | ------- |
| SERVER_NAME    | "Counter-Strike 1.6 DockerServer" | Custom name for server, can be modified later in /hlds/cstrike/server.cfg |
| FAST_DL        | "http://127.0.0.1/cstrike/"       | Full address for fast download site, it can be IP address or domain of your server. Keep in mind, it have to contain 'http' at beginning. Verify if assets are served properly by checking this link in web browser, you should be able to see gfx, maps, models, overviews, sound and sprites directories and their content. Can be modified later in /hlds/cstrike/server.cfg |
| ADMIN_STEAM_ID | "STEAM_0:0:123456"                | Custom SteamID for admin user, can be checked in Counter-Strike console (type 'status' when you are connected to any server). Can be modified (or additional admins can be added) in /hlds/cstrike/addons/amxmodx/configs/users.ini |

In order to edit file, log inside container with `docker exec -it CONTAINER_ID bash`. After that you can run `nano` editor and modify files.

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
docker run --name cs16-server -p 27015:27015/udp -p 27015:27015 -v /path/to/your/server.cfg:/hlds/cstrike/server.cfg archont94/counter-strike1.6:latest
```

Keep in mind the server.cfg file can override the settings from your environment variables:  
`MAP`, `MAXPLAYERS` and `SV_LAN`

## Additional mods

In order to install additional amxmodx mods, follow the instrucitons. Usually it is required to copy files to proper folder (`/hlds/cstrike/addons/amxmodx/plugins`) and modify some config files.

In order to copy files to docker you can use `docker cp` command:

``` bash
docker cp EXTRACTED_MOD_DIRECTORY CONTAINER_ID:/hlds/cstrike/addons/amxmodx
```

Be careful to not overwrite other files. Before any changes, you can always use `docker commit` command to create image with your changes, which you can restore easily later.
