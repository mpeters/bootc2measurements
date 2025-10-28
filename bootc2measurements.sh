#!/usr/bin/bash
set -e

USAGE=$(cat <<-END
    Usage: $0 -i/--image BOOTC_IMAGE [-h/--help]

    optional arguments:
        -o/--output_file FILNAME     (optional name of output file. Defaults to measurements.txt)
        -h/--help                    (show this message and exit)
END
)

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -i=*|--image=*)
        IMAGE=$(echo $key | cut -d '=' -f 2)
        ;;
        -i|--image)
        IMAGE=$2
        shift
        ;;
        -o=*|--output_file=*)
        OUTPUT=$(echo $key | cut -d '=' -f 2)
        ;;
        -o|--output_file)
        OUTPUT=$2
        shift
        ;;
        -h|--help)
        printf "%s\n" "$USAGE"
        exit 0
        shift
        ;;
        *)
                # unknown option
        ;;
        esac
        shift
done

if [[ -z $IMAGE ]]
then
    printf "%s\n" "$USAGE"
    exit 1
fi

if [[ -z $OUTPUT ]]
then
    OUTPUT="measurements.txt"
fi

# do all our scratch work in a temporary directory
TEMP_DIR=$(mktemp -d -t 'bootc2measurements-XXXXXX')
pushd $TEMP_DIR
touch measurements.txt

# download the create_runtime_policy.sh from Keylime
wget https://raw.githubusercontent.com/keylime/keylime/refs/heads/master/scripts/create_runtime_policy.sh
chmod +x create_runtime_policy.sh

# create an entrypoint script to run in the bootccontainer
cat > measure_bootc_files.sh <<END
#!/usr/bin/bash
set -e
pushd /var/run/
bash create_runtime_policy.sh -o measurements.txt -a sha256sum -s '/etc' -y none
TMP_MEASUREMENTS=\$(ls -t /tmp/*/allowlist/measurements.txt | head -n 1)
cp \$TMP_MEASUREMENTS measurements.txt
popd
END
chmod +x measure_bootc_files.sh

# run the script to collect the measurements inside of a container using the given bootc image
podman run --rm -v $TEMP_DIR/create_runtime_policy.sh:/var/run/create_runtime_policy.sh -v $TEMP_DIR/measurements.txt:/var/run/measurements.txt -v $TEMP_DIR/measure_bootc_files.sh:/var/run/measure_bootc_files.sh --security-opt label=disable -it $IMAGE /var/run/measure_bootc_files.sh

popd

# save the output to the desired location
cp $TEMP_DIR/measurements.txt $OUTPUT
rm -rf $TEMP_DIR

