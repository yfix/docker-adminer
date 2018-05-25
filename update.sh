#!/usr/bin/env bash
set -Eeuo pipefail

cd $(dirname $(readlink -f $BASH_SOURCE))

#repo="vrana/adminer"
repo="yfix/adminer"

allVersions="$(
	git ls-remote --tags https://github.com/$repo.git \
		| cut -d$'\t' -f2 \
		| grep -E '^refs/tags/v[0-9]+\.[0-9]+' \
		| cut -dv -f2 \
		| sort -rV
)"

fullVersion="$(
	echo "$allVersions" \
		| head -1
)"
if [ -z "$fullVersion" ]; then
	echo >&2 "error: cannot determine full version for '$version'"
fi

echo "full version: $fullVersion"

downloadSha256="$(
	curl -fsSL "https://github.com/$repo/releases/download/v${fullVersion}/adminer-${fullVersion}.php" \
		| sha256sum \
		| cut -d' ' -f1
)"
echo "  - adminer-${fullVersion}.php: $downloadSha256"

srcDownloadSha256="$(
	curl -fsSL "https://github.com/$repo/archive/v${fullVersion}.tar.gz" \
		| sha256sum \
		| cut -d' ' -f1
)"
echo "  - v${fullVersion}.tar.gz: $srcDownloadSha256"

sed -ri \
	-e 's|^(ENV\s+ADMINER_VERSION\s+).*|\1'"$fullVersion"'|' \
	-e 's|^(ENV\s+ADMINER_DOWNLOAD_SHA256\s+).*|\1'"$downloadSha256"'|' \
	-e 's|^(ENV\s+ADMINER_SRC_DOWNLOAD_SHA256\s+).*|\1'"$srcDownloadSha256"'|' \
	-e 's|^(ENV\s+ADMINER_REPO\s+).*|\1'"$repo"'|' \
	"Dockerfile"
