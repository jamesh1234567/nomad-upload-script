#!/bin/bash
# Upload a calculation directory to a NOMAD instance.
#
# Usage:  nomad_upload.sh <directory> [upload_name]
#
# Requires an upload token in ~/.nomad_token


set -eu

DIR="${1:?usage: nomad_upload.sh <directory> [upload_name]}"
NAME="${2:-$(basename "$(realpath "$DIR")")}"
API="${NOMAD_API:-https://nomad-lab.eu/prod/v1/api/v1}"
TOKEN=$(cat ~/.nomad_token)

TARBALL="/tmp/${NAME}.tar.gz"

echo "packing $DIR"
tar czf "$TARBALL" \
    --exclude=WAVECAR --exclude=CHGCAR --exclude=CHG \
    --exclude=PROCAR --exclude=LOCPOT --exclude=ELFCAR \
    -C "$(dirname "$(realpath "$DIR")")" "$(basename "$(realpath "$DIR")")"

echo "uploading $(du -h "$TARBALL" | cut -f1) as '$NAME'"
curl -sS -X POST -H "Upload-Token: $TOKEN" \
     "$API/uploads?upload_name=$NAME" -T "$TARBALL"
echo

rm -f "$TARBALL"
