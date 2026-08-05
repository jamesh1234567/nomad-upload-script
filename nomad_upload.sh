#!/bin/bash
# Upload a calculation directory to NOMAD.
#
# Usage:  nomad_upload.sh <directory> [upload_name]
#
# [upload_name] is not a requirement but useful to keep track of your own files on NOMAD. 
#
# NOMAD will automatically assign a name to your upload based on the calculation type e.g. "O VASP DFT SinglePoint Simulation" but the [upload_name] you choose will be visible to your in your NOMAD database. 
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
    --exclude=WAVECAR --exclude=CHGCAR --exclude=CHG \   # Excludes large files to reduce size of upload, edit the exclusion to upload these files.
    --exclude=PROCAR --exclude=LOCPOT --exclude=ELFCAR \
    -C "$(dirname "$(realpath "$DIR")")" "$(basename "$(realpath "$DIR")")"

echo "uploading $(du -h "$TARBALL" | cut -f1) as '$NAME'"
curl -sS -X POST -H "Upload-Token: $TOKEN" \
     "$API/uploads?upload_name=$NAME" -T "$TARBALL"
echo

rm -f "$TARBALL"
