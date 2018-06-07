#!/usr/bin/env bash
set -ue

readonly S3REPO_PLUGIN="https://raw.githubusercontent.com/clburlison/\
Munki-s3Repo-Plugin/master/s3Repo.py"
readonly CURRENT_MUNKI_ZIP_URL=$(python -c 'import urllib2,json;\
  resp = urllib2.urlopen("https://api.github.com/repos/munki/munki/releases");\
  html = resp.read(); obj=json.loads(html);print(obj[0]["zipball_url"])')

function cleanup () {
  echo "Clean up temp files..."
  rm -rf ./munki.zip client munki-munki-*
}

function dl_munkitools () {
  echo "Download the most current release of munki..."
  curl -sL -o ./munki.zip --connect-timeout 30 ${CURRENT_MUNKI_ZIP_URL}
}

function prep_munkitools () {
  echo "Move munki code into temp directory structure..."
  unzip -a ./munki.zip
  mv munki-munki-*/code/client ./
}

function dl_repo_plugin () {
  echo "Download latest s3 repo plugin..."
  curl ${S3REPO_PLUGIN} -o client/munkilib/munkirepo/s3Repo.py
}

function zip_lambda_func () {
  echo "Zip the lambda function..."
  find client -type f -name "*.pyc" -delete
  zip -r lambda_payload.zip client/ lambda_makecatalogs.py
}

function main() {
  cleanup
  dl_munkitools
  prep_munkitools
  dl_repo_plugin
  zip_lambda_func
  cleanup
  echo "Lambda build complete!"
}

main
