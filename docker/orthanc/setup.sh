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

# Specifying the target setup procedure path is mandatory
if [[ ! $1 ]]; then
	exit 1
fi

# Parameters set in setup procedures:
#
# name: The abbreviated name for the setup procedure set.
#
#   Mandatory.
#   Should be uppercase.
#   Should be quite short.
#   Will be used in log messages.
#   Will be used as prefix for environment variables.
#   Multiple setup procedures can use the setup procedure set name.
#
# plugin: Orthanc plugin shared library
#
#   Optional.
#   Can't be used with 'plugins'.
#
#   The name of the plugin (filename without path or extension) the setup
#   procedure is installing.  Don't specify if the setup procedure is not
#   installing a plugin.
#   See also 'plugins'.
#
# plugins: Set of Orthanc plugins
#
#   Optional.
#   Can't be used with 'plugin'.
#   Array of plugin names (see 'plugin').
#
# conf: Orthanc configuration file
#
#   Optional.
#   Filename of the configuration (filename without path or extension) the
#   setup procedure is generating.
#
# default: Specify whether the bundle settings are used by default or not
#
#   Optional.
#   Requires 'conf' to be set.
#   If set to "true" and a configuration file is not already present in a
#   lower-level image layer, then generate the configuration file using the
#   default parameter values of the bundle (which may be different from the
#   defaults of Orthanc itself).  If one or more plugins are specified, they
#   are automatically enabled.  Can be overriden with the BUNDLE_DEFAULTS
#   setting.
#
# settings: List of environment variables used by the setup procedure set
#
#   Optional.
#   Names of environment variables, without the setup procedure set name
#   prefix.
#
#   Reserved settings: ENABLED, BUNDLE_DEFAULTS.
#
# secrets: Docker secrets
#
#   Optional.
#   List of settings that are secrets (keys, passwords, etc) to be retrieved
#   first from environment variables (as usual) then (preferrably) from Docker
#   secrets.  The Docker secret file names can be specified with the
#   ${NAME}_${SETTING}_SECRET environment variable and will default to
#   ${NAME}_${SETTING}.
#
declare name default plugin plugins conf settings secrets


# Simple log output facility.  Can be used in setup procedures, but only after
# the mandatory 'name' parameter is set.
function log {
	echo -e "$name: $*" >&2
}


# The setup procedure is executed in the same shell context (and thus same
# process) as the setup executor.
#
# Recall: One setup procedure executor process is run per setup procedure.
#
# shellcheck source=/dev/null
source "$1"


# Basic setup procedure validation

if [[ ! $name ]]; then
	exit 2
fi

if [[ $plugin ]] && ((${#plugins[@]})); then
	exit 6
elif [[ $plugin ]]; then
	plugins=("$plugin")
	unset plugin
fi


# getenv: Outputs the environment variable for given setting.
#
# Note that each setting set via the environment for the setup procedure is
# prefixed with the abbreviated name of the setup procedure set.
#
function getenv {
	eval echo "\$${name}_$1"
}


# gensecret: Generate a variable for given secret setting.
#
# Will use the corresponding environment variable if available, but users are
# encouraged to use Docker secrets, which it will then use instead.  The
# filename of the secret can be set with the ${NAME}_${SETTING_SECRET}
# environment variable, and will default to the same name as the environment
# variable name of the setting (${NAME}_${SETTING}).
#
# The intent of this function is to be a pre-processor for setup procedure
# settings: the generated variable for the secret will have the same name as
# what the environment variable for the corresponding setting would have had
# if the user set it, even if the user only uses Docker secrets.
#
# Note: This variable is not exported to the environment and will thus remain
# contained to the setup executor process context before it is likely written
# out by the configuration generator of the setup procedure.  No secrets will
# be passed in child processes unless the user explicitly sets environment
# variables.
#
function gensecret {
	local setting=$1 value secret file
	variable=${name}_${setting}
	value=$(getenv "$setting")
	if [[ $value ]]; then
		return
	fi
	secret=$(getenv "${setting}_SECRET")
	file=/run/secrets/${secret:-$variable}
	if [[ -e $file ]]; then
		eval "$variable=$(<"$file")"
	fi
}


# processenv: Indicate whether user-settings are defined and process them.
#
# Returns 0 if at least one setting has been passed via the environment.
# Returns a non-zero value otherwise.
#
# The abbreviated setup procedure set name is stripped from each setting name
# for convenience.
#
function processenv {
	local ret=1 value
	for setting in "${settings[@]}"; do
		value=$(getenv "$setting")
		if [[ $value ]]; then
			eval "$setting=$value"
			ret=0
		fi
	done
	return $ret
}


# Generate variables from Docker secrets if corresponding variables have not
# been passed via the environment already.
for secret in "${secrets[@]}"; do
	gensecret "$secret"
done


# If the user explicitly defines whether to use bundle defaults or not,
# respect that wish by overriding the setup procedure 'default' parameter.
usedefaults=$(getenv BUNDLE_DEFAULTS)
if [[ $usedefaults ]]; then
	default=$usedefaults
fi


# Set absolute path of target configuration file if specified.
if [[ $conf ]]; then
	conf=/etc/orthanc/$conf.json
fi


# Optional configuration file generation.
if [[ -e $conf ]]; then
	log "'$conf' taking precendence over related environment variables"
	if ((${#plugins[@]})); then
		enabled=true
	fi
else
	if ((${#plugins[@]})); then
		enabled=$(getenv ENABLED)
	fi
	if processenv || [[ $default == true ]]; then
		if [[ ! $conf ]]; then
			exit 3
		fi
		if [[ $(type -t genconf) != function ]]; then
			exit 4
		fi
		log "Generating '$conf'..."
		genconf "$conf"
		if ((${#plugins[@]})); then
			enabled=true
		fi
	fi
fi

# Optional plugin installation.
#
# To summarize, the plugin or plugins managed by the setup procedure will be
# enabled if either:
#
# - The corresponding configuration file is already defined in lower-level
# image layer,
# - ${NAME}_ENABLED is set to true in the environment,
# - At least one setup procedure setting is set in the environment,
# - The procedure is set to use the default settings of the bundle,
if [[ $enabled == true ]]; then
	if ! ((${#plugins[@]})); then
		exit 5
	fi
	for plugin in "${plugins[@]}"; do
		log "Enabling plugin '$plugin'"
		mv /usr/share/orthanc/plugins{-disabled,}/"$plugin".so
	done
fi
