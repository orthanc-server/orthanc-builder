name=LOCALE
conf=locale
globals=(LOCALE)
function genconf {
	cat <<-EOF >"$1"
	{
		"Locale": "${LOCALE:-en_US.UTF-8}"
	}
	EOF
}
