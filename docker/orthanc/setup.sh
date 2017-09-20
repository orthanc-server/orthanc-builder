#!/usr/bin/env bash
#
# OVERVIEW
#
# Execute a setup procedure for Orthanc.
#
# A single setup procedure can optionally write a single Orthanc
# configuration file ('conf' variable), can optionally enable one or
# more plugins ('plugin' and 'plugins' variables), and is provided with
# support facilities like 'log' and 'secret'.
#
# EXIT STATUS
#
# 1: No setup procedure path given (first argument)
# 2: No procedure name is defined in setup file ('name' variable)
# 3: Env-var set but no conf file path defined in setup file ('conf' variable)
# 4: No configuration generator defined in setup file ('genconf' function)
# 5: Internal error: trying to enable undefined plugin
# 6: Procedure attempted to define both 'plugin' and 'plugins' variables
# 127: A command failed

set -o errexit

if [[ ! $1 ]]; then
	exit 1
fi

declare name plugin plugins conf settings secrets

function log {
	echo -e "$name: $*" >&2
}

# shellcheck source=/dev/null
source "$1"

if [[ ! $name ]]; then
	exit 2
fi

if [[ $plugin ]] && ((${#plugins[@]})); then
	exit 6
elif [[ $plugin ]]; then
	plugins=("$plugin")
	unset plugin
fi

function gensecret {
	local variable=${name}_$1 value secret file
	eval value="\$$variable"
	if [[ $value ]]; then
		# shellcheck disable=SC2163
		export -n "$variable"
		return
	fi
	eval secret="\$${variable}_SECRET"
	file=/run/secrets/${secret:-$variable}
	if [[ -e $file ]]; then
		eval "$variable=$(<"$file")"
	fi
}

function processenv {
	local ret=1 variable value
	for setting in "${settings[@]}"; do
		variable="${name}_${setting}"
		eval value="\$$variable"
		unset "$variable"
		if [[ $value ]]; then
			eval "$setting=$value"
			ret=0
		fi
	done
	return $ret
}

for secret in "${secrets[@]}"; do
	gensecret "$secret"
done

if [[ $conf ]]; then
	conf=/etc/orthanc/$conf.json
fi

if [[ -e $conf ]]; then
	log "'$conf' taking precendence over related environment variables"
	if ((${#plugins[@]})); then
		enabled=true
	fi
else
	if ((${#plugins[@]})); then
		eval enabled="\$${name}_ENABLED"
	fi
	if processenv; then
		if [[ ! $conf ]]; then
			exit 3
		fi
		if [[ $(type -t genconf) != function ]]; then
			exit 4
		fi
		log "Generating '$conf' from environment variables"
		genconf "$conf"
		if ((${#plugins[@]})); then
			enabled=true
		fi
	fi
fi
if [[ $enabled ]]; then
	if ! ((${#plugins[@]})); then
		exit 5
	fi
	for plugin in "${plugins[@]}"; do
		log "Enabling plugin '$plugin'"
		mv /usr/share/orthanc/plugins{-disabled,}/"$plugin".so
	done
fi
