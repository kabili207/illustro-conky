return {

	{
		x=5,
		y=8,
		boxes={
			{
				title='System',
				values= {
					{
						title='CPU Usage',
						value='${cpu cpu0}',
						suffix='%',
						max=100
					},
					--{
					--	title='Core 1 Freq',
					--	v_type='cmd',
					--	value='awk \'/cpu MHz/{i++}i==1{printf "%.f",$4; exit}\' /proc/cpuinfo',
					--	suffix='MHz',
					--	max=4000
					--},
					{
						title='RAM Usage',
						value='${memperc}',
						suffix='%',
						max=100
					},
					{
						title='Swap Usage',
						value='${swapperc}',
						suffix='%',
						max=100
					},
					{
						title='GPU Usage',
						v_type='cmd',
						value='nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader | awk \'{print $1}\'',
						suffix='%',
						max=100
					},
					{
						title='GPU Memory Usage',
						v_type='cmd',
						value='nvidia-smi --query-gpu=utilization.memory --format=csv,noheader | awk \'{print $1}\'',
						suffix='%',
						max=100
					},
					{
						title='UPS Battery Level',
						v_type='cmd',
						value='upsc ups@shiori | grep battery.charge: | awk \'{print $2}\'',
						suffix='%',
						max=100
					},
				}
			},

			{
				title='Disks',
				values={
					{
						title='root',
						value='${fs_used_perc /}',
						suffix='%',
						max=100,
						interval=10
					},
					{
						title='media',
						value='${fs_used_perc /mnt/media}',
						suffix='%',
						max=100,
						interval=10
					},
					{
						title='games',
						value='${fs_used_perc /mnt/games}',
						suffix='%',
						max=100,
						interval=10
					},
					{
						title='games2',
						value='${fs_used_perc /mnt/games2}',
						suffix='%',
						max=100,
						interval=10
					},
					{
						title='fumiko',
						value='${fs_used_perc /mnt/videos}',
						suffix='%',
						max=100,
						interval=10
					},
				}
			},

			{
				title='Temperatures',
				values={
					{
						title='CPU Temp',
						value='${hwmon 1 temp 1}',
						suffix=' C', -- conky can't handle °
						precision=0,
						max=90
					},
					{
						title='GPU Temp',
						v_type='cmd',
						value='nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader',
						suffix=' C',
						max=90,
						precision=0,
						interval=10
					},
					{
						title='Linux (sda)',
						v_type='cmd',
						value='/home/kabili/bin/udisks-temp sda',
						suffix=' C',
						max=60,
						precision=0,
						interval=10
					},
					{
						title='Games 1 (sdb)',
						v_type='cmd',
						value='/home/kabili/bin/udisks-temp sdb',
						suffix=' C',
						max=60,
						precision=0,
						interval=10
					},
					{
						title='Games 2 (sdc)',
						v_type='cmd',
						value='/home/kabili/bin/udisks-temp sdc',
						suffix=' C',
						max=60,
						precision=0,
						interval=10
					},
					{
						title='Media (sdd)',
						v_type='cmd',
						value='/home/kabili/bin/udisks-temp sdd',
						suffix=' C',
						max=60,
						precision=0,
						interval=10
					},
				}
			},

			{
				title='Portage',
				values={
					{
						title='Last Sync',
						v_type='cmd',
						value='/home/kabili/bin/conky/lastsync.pl',
						suffix='',
						max=100,
						interval=90
					},
					{
						title='Progress',
						v_type='cmd',
						value='/home/kabili/bin/conky/emerge-progress.sh',
						suffix='%',
						max=100,
						precision=0,
						interval=30
					},
				}
			},
		}
	},
	{
		x=1361,
		y=8,
		align='right',
		boxes={
			{
				title='Environment',
				values={
					{
						title='Outside',
						v_type='cmd',
						value='/home/kabili/bin/get-openhab-state.sh Outdoor_Temperature | awk \'{print $1}\'',
						suffix=' F',
						max=100,
						precision=0,
						interval=360
					},
					{
						title='Living Room',
						v_type='cmd',
						--value='get-openhab-state.sh Temp_Living | awk \'{print (9/5)*$1+32}\'',
						value='/home/kabili/bin/get-openhab-state.sh Temp_Living | awk \'{print $1}\'',
						suffix=' F',
						max=100,
						precision=0,
						interval=360
					},
					{
						title='Kitchen',
						v_type='cmd',
						value='/home/kabili/bin/get-openhab-state.sh Temp_Kitchen | awk \'{print $1}\'',
						suffix=' F',
						max=100,
						precision=0,
						interval=360
					},
					{
						title='Bedroom',
						v_type='cmd',
						value='/home/kabili/bin/get-openhab-state.sh Temp_FrontBedroom | awk \'{print $1}\'',
						suffix=' F',
						max=100,
						precision=0,
						interval=360
					},
					{
						title='Office',
						v_type='cmd',
						value='/home/kabili/bin/get-openhab-state.sh Temp_RearBedroom | awk \'{print $1}\'',
						suffix=' F',
						max=100,
						precision=0,
						interval=360
					},
					{
						title='Garage',
						v_type='cmd',
						value='/home/kabili/bin/get-openhab-state.sh Temp_Garage | awk \'{print $1}\'',
						suffix=' F',
						max=100,
						precision=0,
						interval=360
					},
				}
			},

			{
				title='Network',
				values={
					{
						title='Address',
						value='${addr eno1}',
						suffix='',
						max=100
					},
					{
						title='Down',
						value='${downspeed eno1}',
						suffix='',
						max=100
					},
					{
						title='Up',
						value='${upspeed eno1}',
						suffix='',
						max=100
					},
				}
			},

			{
				title='Fans',
				values={
					{
						title='CPU Fan',
						value='${hwmon 2 fan 2}',
						suffix=' RPM',
						max=3500
					},
					--{
					--	title='Front Fan',
					--	value='${platform it87.656 fan 4}',
					--	suffix=' RPM',
					--	max=2800
					--},
					{
						title='Rear Fan',
						value='${hwmon 2 fan 5}',
						suffix=' RPM',
						max=2000
					},
					{
						title='GPU Fan',
						v_type='cmd',
						value='nvidia-smi --query-gpu=utilization.memory --format=csv,noheader | awk \'{print $1}\'',
						suffix='%',
						max=100,
						interval=5
					},
				}
			},

			{
				title='Music',
				values={
					{
						type='mpris'
					},
				}
			},
		}
	},
}
