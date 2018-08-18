return {

	{
		title='System',
		values= {
			{
				title='CPU Usage',
				value='${cpu cpu0}',
				suffix='%',
				max=100
			},
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
				value='nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader | awk \'{print \$1}\'',
				suffix='%',
				max=100
			},
			{
				title='GPU Memory Usage',
				v_type='cmd',
				value='nvidia-smi --query-gpu=utilization.memory --format=csv,noheader | awk \'{print \$1}\'',
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
				title='home',
				value='${fs_used_perc /home}',
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
				title='shiori',
				value='${fs_used_perc /mnt/videos}',
				suffix='%',
				max=100,
				interval=10
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
		title='Temperatures',
		values={
			{
				title='CPU Temp',
				value='${hwmon 1 temp 1}',
				suffix=' C', -- conky can't handle °
				max=90
			},
			{
				title='GPU Temp',
				v_type='cmd',
				value='nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader',
				suffix=' C',
				max=90,
				interval=10
			},
			{
				title='Linux (sda)',
				v_type='cmd',
				value='udisks --show-info /dev/sda | grep airflow-temperature-celsius | cut -c 52-53',
				suffix=' C',
				max=60,
				interval=10
			},
			{
				title='Windows (sdb)',
				v_type='cmd',
				value='udisks --show-info /dev/sdb | grep airflow-temperature-celsius | cut -c 52-53',
				suffix=' C',
				max=60,
				interval=10
			},
			{
				title='Games (sdc)',
				v_type='cmd',
				value='udisks --show-info /dev/sdc | grep temperature-celsius-2 | cut -c 52-53',
				suffix=' C',
				max=60,
				interval=10
			},
			{
				title='Media (sdd)',
				v_type='cmd',
				value='udisks --show-info /dev/sdd | grep temperature-celsius-2 | cut -c 52-53',
				suffix=' C',
				max=60,
				interval=10
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
				value='nvidia-smi -a | grep Fan | awk \'{print \$4}\'',
				suffix='%',
				max=100,
				interval=5
			},
		}
	},

	{
		title='Portage',
		values={
			{
				title='Last Sync',
				v_type='cmd',
				value='/home/kabili/bin/lastsync.pl',
				suffix='',
				max=100,
				interval=90
			},
			{
				title='Progress',
				v_type='cmd',
				value='/home/kabili/bin/emerge-progress.sh',
				suffix='%',
				max=100,
				interval=30
			},
		}
	},

	{
		title='Environment',
		values={
			{
				title='Outside',
				v_type='cmd',
				value='curl --silent http://192.168.77.40:8080/rest/items/Outdoor_Temperature/state',
				suffix=' F',
				max=100,
				precision=0,
				interval=360
			},
			{
				title='Living Room',
				v_type='cmd',
				value='curl --silent http://192.168.77.40:8080/rest/items/Temp_Living/state',
				suffix=' F',
				max=100,
				precision=0,
				interval=360
			},
			{
				title='Bedroom',
				v_type='cmd',
				value='curl --silent http://192.168.77.40:8080/rest/items/Temp_Bedroom/state',
				suffix=' F',
				max=100,
				precision=0,
				interval=360
			},
		}
	},
}
