#!/bin/sh

path="$(dirname "$0")"
bg_bar_color="#2E3440"

declare -A bgColor
declare -A fgColor

bgColor['ip']="#C49D58"
fgColor['ip']="#333333"

bgColor['disk']="#3949AB"
fgColor['disk']="#EEEEEE"

bgColor['mem']="#B87238"
fgColor['mem']="#DDDDDD"

bgColor['cpu']="#A7282E"
fgColor['cpu']="#FFFFFF"

bgColor['date']="#80B3B1"
fgColor['date']="#333333"

bgColor['vol']="#3B8E77"
fgColor['vol']="#222222"


separator() {
  echo -n "{"
  echo -n "\"full_text\":\"\"," # CTRL+Ue0b2
  echo -n "\"separator\":false,"
  echo -n "\"separator_block_width\":0,"
  echo -n "\"border\":\"$bg_bar_color\","
  echo -n "\"border_left\":0,"
  echo -n "\"border_right\":0,"
  echo -n "\"border_top\":0,"
  echo -n "\"border_bottom\":0,"
  echo -n "\"color\":\"$1\","
  echo -n "\"background\":\"$2\""
  echo -n "}"
}

common() {
  echo -n "\"border\": \"$bg_bar_color\","
  echo -n "\"separator\":false,"
  echo -n "\"separator_block_width\":0,"
  echo -n "\"border_top\":0,"
  echo -n "\"border_bottom\":0,"
  echo -n "\"border_left\":0,"
  echo -n "\"border_right\":0"
}

myip_local() {
  separator ${bgColor["ip"]} $bg_bar_color
  echo -n ",{"
  echo -n "\"name\":\"ip_local\","
  echo -n "\"full_text\":\"  $(ip route get 1 | sed -n 's/.*src \([0-9.]\+\).*/\1/p') \","
  echo -n "\"color\":\"${fgColor['ip']}\","
  echo -n "\"background\":\"${bgColor['ip']}\","
  common
  echo -n "},"
}

disk_usage() {
  separator ${bgColor['disk']} ${bgColor['ip']}
  echo -n ",{"
  echo -n "\"name\":\"id_disk_usage\","
  echo -n "\"full_text\":\"  $($path/disk.py)% \" ,"
  echo -n "\"color\":\"${fgColor['disk']}\","
  echo -n "\"background\":\"${bgColor['disk']}\","
  common
  echo -n "},"
}

memory() {
  separator ${bgColor['mem']} ${bgColor['disk']}
  echo -n ",{"
  echo -n "\"name\":\"id_memory\","
  echo -n "\"full_text\":\"  $($path/memory.py)% \","
  echo -n "\"color\":\"${fgColor['mem']}\","
  echo -n "\"background\":\"${bgColor['mem']}\","
  common
  echo -n "},"
}

cpu_usage() {
  separator ${bgColor['cpu']} ${bgColor['mem']}
  echo -n ",{"
  echo -n "\"name\":\"id_cpu_usage\","
  echo -n "\"full_text\":\"  $($path/cpu.py)% \" ,"
  echo -n "\"color\":\"${fgColor['cpu']}\","
  echo -n "\"background\":\"${bgColor['cpu']}\","
  common
  echo -n "},"
}

mydate() {
  separator ${bgColor['date']} ${bgColor['cpu']}
  echo -n ",{"
  echo -n "\"name\":\"id_time\","
  echo -n "\"full_text\":\"  $(date "+%a %d/%m %H:%M") \","
  echo -n "\"color\":\"${fgColor['date']}\","
  echo -n "\"background\":\"${bgColor['date']}\","
  common
  echo -n "},"
}

volume() {
  separator ${bgColor['vol']} ${bgColor['date']}
  vol=$(pamixer --get-volume)
  echo -n ",{"
  echo -n "\"name\":\"id_volume\","
  if [ $vol -le 0 ]; then
    echo -n "\"full_text\":\"  ${vol}% \","
  else
    echo -n "\"full_text\":\"  ${vol}% \","
  fi
  echo -n "\"color\":\"${fgColor['vol']}\","
  echo -n "\"background\":\"${bgColor['vol']}\","
  common
  echo -n "},"
  separator $bg_bar_color ${bgColor['vol']}
}


# https://github.com/i3/i3/blob/next/contrib/trivial-bar-script.sh
echo '{ "version": 1, "click_events":true }'     # Send the header so that i3bar knows we want to use JSON:
echo '['                    # Begin the endless array.
echo '[]'                   # We send an empty first array of blocks to make the loop simpler:

(while :;
do
  echo -n ",["
    myip_local
    disk_usage
    memory
    cpu_usage
    mydate
    volume
  echo "]"
  sleep 10
done)
