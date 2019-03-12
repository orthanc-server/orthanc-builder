#!/usr/bin/env bash
name=UMD
conf=usermetadata
globals=(USERMETADATA)
function genconf {
	cat <<-EOF >"$1"
	{
		"UserMetadata": ${USERMETADATA:-"{}"}
	}
	EOF
}
