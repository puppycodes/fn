#!/bin/bash
set -ex

user="fnproject"
image="fnlb"

# ensure working dir is clean
git status
if [[ -z $(git status -s) ]]
then
  echo "tree is clean"
else
  echo "tree is dirty, please commit changes before running this"
  exit 1
fi

version=$(grep -m1 -Eo "[0-9]+\.[0-9]+\.[0-9]+" $version_file)
echo "Version: $version"

# Push the version bump and tags laid down previously
gtag=$image-$version
git push
git push origin $gtag

# Finally, push docker images
docker push $user/$image:$version
docker push $user/$image:latest
