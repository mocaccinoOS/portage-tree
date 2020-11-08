
force_single_mirror () {
	local mirror=$1
  local repo="${2:-sabayonlinux.org}"
  local entropy_append=${3:-1}
  local url="$mirror"

  if [ "$entropy_append" == "1" ] ; then
    url=${url}/entropy
  fi

  # Temporary workaround for fetching data.
  echo "
[${repo}]
desc = Sabayon Linux Official Repository

repo = $mirror#bz2
pkg = $mirror
" > /etc/entropy/repositories.conf.d/entropy_$repo
}

#force_single_mirror "http://sabayonlinux.mirror.garr.it/sabayon"
force_single_mirror "http://pkg.sabayon.org" "sabayonlinux.org" "0"
