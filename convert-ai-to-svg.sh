#! /bin/bash

set -eu

input=$1
clean="${input}.clean"
output="${input}.svg"

verbose="${VERBOSE:-false}"

last_progress_time=$(date +%s)
progress_timeout=1

# make file readable
tr -cs '[:print:]' '[\n*]' < "${input}" > "${clean}"
lines=$(wc -l < "${clean}")

# defaults for header
x=0
y=0
width=500
height=500

state="header"
data=""

function writeHeader {
    echo "<svg width=\"$width\" height=\"$height\" viewBox=\"$x $y $width $height\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">" > "${output}"
}

function writeData {
    data=${data::-1}
    echo "    <path d=\"${data}\" stroke=\"black\" fill=\"transparent\" style=\"fill:none;stroke-width:10\" />" >> "${output}"
    data=""
}

line_number=1;
while IFS= read -r line || [[ -n "$line" ]]; do
    if [ "$state" == "header" ]; then
        if [ "$line" == "%%EndSetup" ]; then
            state="ready"
            writeHeader
        elif [[ "$line" =~ ^%%BoundingBox.* ]]; then
            x=$(echo "$line" | cut -d' ' -f 2)
            y=$(echo "$line" | cut -d' ' -f 3)
            width=$(echo "$line" | cut -d' ' -f 4)
            height=$(echo "$line" | cut -d' ' -f 5)
        fi
    elif [ "$line" == "1 XR" ]; then
        state="begin path"
    elif [ "$line" == "N" ] || [ "$line" == "n" ]; then
        # write path to file
        if [ "$state" != "header" ]; then
            if [ "$data" == "" ]; then
                echo "[ERROR] Empty data before line $line_number"
                exit 17
            else
                state="can begin path"
                writeData
            fi
        fi
    elif [ "$state" == "begin path" ]; then
        state="continue path"
        data="M "
        data+=$(echo "$line" | grep -oP '\d+\.?\d* \d+\.?\d*' | head -1)
        data+=" "
    elif [ "$state" == "can begin path" ]; then
        if echo "$line" | grep -oP '(?:\d+\.?\d* ){2}m' > /dev/null ; then
            state="continue path"
            data="M "
            data+=$(echo "$line" | grep -oP '\d+\.?\d* \d+\.?\d*' | head -1)
            data+=" "
        else
            state="ready"
        fi
    elif [ "$state" == "continue path" ]; then
        current=$(echo "$line" | tr '[:upper:]' '[:lower:]' | grep -oP '\d+\.?\d* \d+\.?\d*' | tr '\n' ' ')
        if [ "$current" == "" ]; then
            echo "[ERROR] Unrecognized command in line $line_number: $line"
            exit 13
        fi
        command=$(echo "$line" | tail -c 2 | tr '[:lower:]' '[:upper:]')
        if [ "$command" == "V" ]; then
            command="S"
        elif [ "$command" == "Y" ]; then
            # relies on previous data and creates new path
            command="S"
            last_values=$(echo "$data" | awk -F' ' '{print $(NF-1) FS $(NF)}')
            writeData
            data="M ${last_values} "
        fi
        data+="$command $current"
    fi
    # print progress
    if [ "$verbose" == "true" ]; then
        let next_progress_time=last_progress_time+progress_timeout
        if [ "$next_progress_time" -lt "$(date +%s)" ]; then
        progress=$(awk -v line=$line_number -v lines=$lines 'BEGIN { printf"%0.1f\n", line*100/lines }')
        last_progress_time=$(date +%s)
        echo "[INFO] ${progress}%"
        fi
    fi
    # increment line
    let line_number=line_number+1
done < "${clean}"
rm "${clean}"

echo "</svg>" >> "${output}"
if [ "$verbose" == "true" ]; then
    echo "[INFO] Done"
fi
