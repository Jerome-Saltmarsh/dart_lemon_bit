# Get the directory where the script is located
script_dir="$(dirname "$0")"

echo script_dir
# Create the symlink using the script's location
mklink /J "${script_dir}/gamestream_http/lib/packages/gamestream_firestore" "${script_dir}/gamestream_firestore/lib"

read username