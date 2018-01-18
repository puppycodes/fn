#!/bin/sh

set -e

# Has a subset of the tree changed since the last tag of a particular kind?
# (If so, we'll need to rebuild and re-release, assuming the tests pass.)

RELEASE_BRANCH=origin/master
FIRST_COMMIT="$(git rev-list "$RELEASE_BRANCH" | tail -1)"

FN_TAG="$(git tag --merged "$RELEASE_BRANCH" --sort='v:refname' '[0-9]*' | tail -1)"
FN_PREV="$FN_TAG"
[[ -z "$FN_TAG" ]] && FN_TAG="$FIRST_COMMIT"
[[ -z "$FN_PREV" ]] && FN_PREV=0.0.0

FNLB_TAG="$(git tag --merged "$RELEASE_BRANCH" --sort='v:refname' 'fnlb-*' | tail -1)"
FNLB_PREV="$FNLB_TAG"
[[ -z "$FNLB_TAG" ]] && FNLB_TAG="$FIRST_COMMIT"
[[ -z "$FNLB_PREV" ]] && FNLB_PREV=0.0.0

DIND_TAG="$(git tag --merged "$RELEASE_BRANCH" --sort='v:refname' 'dind-*' | tail -1)"
DIND_PREV="$DIND_TAG"
[[ -z "$DIND_TAG" ]] && DIND_TAG="$FIRST_COMMIT"
[[ -z "$DIND_PREV" ]] && DIND_PREV=dind-0.0.0

# Which pieces of the tree are changed since to each tag?
# We are only interested in parts of the tree corresponding to each tag's aegis
# We are *not* interested in solely-DIND or solely-FNLB changes if we're considering
# a release of fnserver

# DIND bumps only if there are changes under images/dind.
[[ -n "$(git diff --dirstat=files,0,cumulative "$DIND_TAG" | awk '$2 ~ /^(images\/dind)\/$/')" ]] && DIND_CHANGED=yes

# FNLB bumps only if there are changes under fnlb/ or vendor/
[[ -n "$(git diff --dirstat=files,0,cumulative "$FNLB_TAG" | awk '$2 ~ /^(fnlb|vendor)\/$/')" ]] && FNLB_CHANGED=yes

# FN bumps only if there are changes *other* than fnlb/ or images/dind/
[[ -n "$(git diff --dirstat=files,0,cumulative "$FN_TAG" | awk '$2 !~ /^(images\/dind|fnlb)\/$/')" ]] && FN_CHANGED=yes

# Finally, some of these pieces are used as build tools for later ones.
[[ -n "$DIND_CHANGED" && -z "$FN_CHANGED" ]] && FN_CHANGED=dep

cat <<-EOF
	# Change summary: "dep" means a rebuild required due to a dependency change
	DIND_CHANGED=$DIND_CHANGED
	DIND_TAG="$DIND_TAG"
	DIND_PREV="$DIND_PREV"

	FNLB_CHANGED=$FNLB_CHANGED
	FNLB_TAG="$FNLB_TAG"
	FNLB_PREV="$FNLB_PREV"

	FN_CHANGED=$FN_CHANGED
	FN_TAG="$FN_TAG"
	FN_PREV="$FN_PREV"
	EOF
