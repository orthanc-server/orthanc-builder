name=GCP_DICOM
conf=gcp-dicom
settings=(
	ACCOUNTS
	ACCOUNT_NAME
	PROJECT
	LOCATION
	DATASET
	DATASTORE
	AUTHORIZED_SERVICE_ACCOUNT_FILE
	AUTHORIZED_USER_FILE
	AUTHORIZED_USER_CLIENT_ID
	AUTHORIZED_USER_CLIENT_SECRET
	AUTHORIZED_USER_REFRESH_TOKEN
	BASE_URL
)
secrets=(
	AUTHORIZED_USER_CLIENT_SECRET
	AUTHORIZED_USER_REFRESH_TOKEN
)
plugin=libOrthancGoogleCloudPlatform
function auth_methods_used {
	local methods=(
		AUTHORIZED_SERVICE_ACCOUNT_FILE
		AUTHORIZED_USER_FILE
		AUTHORIZED_USER_CLIENT_ID
	)
	local method methods_used=0
	for method in "${methods[@]}"; do
		if [[ ${!method} ]]; then
			((methods_used++))
		fi
	done
	echo $methods_used
}
function genconf {
	if [[ $ACCOUNTS && ( \
		$ACCOUNTS_NAME || \
		$PROJECT || \
		$LOCATION || \
		$DATASET || \
		$DATASTORE || \
		$AUTHORIZED_SERVICE_ACCOUNT_FILE || \
		$AUTHORIZED_USER_FILE || \
		$AUTHORIZED_USER_CLIENT_ID || \
		$AUTHORIZED_USER_CLIENT_SECRET || \
		$AUTHORIZED_USER_REFRESH_TOKEN ) \
	]]; then
		err "Cannot set both ACCOUNTS and single-account mode settings"
		return 1
	fi
	if ((auth_methods_used > 1)); then
		err "Must use only one authentication method"
		return 2
	fi
	BASE_URL=${BASE_URL:-https://healthcare.googleapis.com/v1beta1/}
	if [[ $ACCOUNTS ]]; then
		cat <<-EOF >"$1"
		{
			"GoogleCloudPlatform": {
				"Accounts": ${ACCOUNTS:-"{}"},
				"BaseUrl": "$BASE_URL"
			}
		}
		EOF
	elif [[ $ACCOUNT_NAME ]]; then
		if [[ ! $PROJECT ]]; then
			err "Missing PROJECT setting"
			return 4
		fi
		if [[ ! $LOCATION ]]; then
			err "Missing LOCATION setting"
			return 5
		fi
		if [[ ! $DATASET ]]; then
			err "Missing DATASET setting"
			return 6
		fi
		if [[ ! $DATASTORE ]]; then
			err "Missing DATASTORE setting"
			return 7
		fi
		if [[ $AUTHORIZED_SERVICE_ACCOUNT_FILE ]]; then
			cat <<-EOF >"$1"
			{
				"GoogleCloudPlatform": {
					"Accounts": {
						"$ACCOUNT_NAME": {
							"Project": "$PROJECT",
							"Location": "$LOCATION",
							"Dataset": "$DATASET",
							"DicomStore": "$DATASTORE",
							"ServiceAccountFile": "$AUTHORIZED_SERVICE_ACCOUNT_FILE"
						}
					},
					"BaseUrl": "$BASE_URL"
				}
			}
			EOF
		elif [[ $AUTHORIZED_USER_FILE ]]; then
			cat <<-EOF >"$1"
			{
				"GoogleCloudPlatform": {
					"Accounts": {
						"$ACCOUNT_NAME": {
							"Project": "$PROJECT",
							"Location": "$LOCATION",
							"Dataset": "$DATASET",
							"DicomStore": "$DATASTORE",
							"AuthorizedUserfile": "$AUTHORIZED_USER_FILE"
						}
					},
					"BaseUrl": "$BASE_URL"
				}
			}
			EOF
		elif [[ $AUTHORIZED_USER_CLIENT_ID ]]; then
			if [[ ! $AUTHORIZED_USER_CLIENT_SECRET ]]; then
				err "Missing AUTHORIZED_USER_CLIENT_SECRET setting"
				return 8
			fi
			if [[ ! $AUTHORIZED_USER_REFRESH_TOKEN ]]; then
				err "Missing AUTHORIZED_USER_REFRESH_TOKEN setting"
				return 9
			fi
			cat <<-EOF >"$1"
			{
				"GoogleCloudPlatform": {
					"Accounts": {
						"$ACCOUNT_NAME": {
							"Project": "$PROJECT",
							"Location": "$LOCATION",
							"Dataset": "$DATASET",
							"DicomStore": "$DATASTORE",
							"AuthorizedUserClientId": "$AUTHORIZED_USER_CLIENT_ID",
							"AuthorizedUserClientSecret": "$AUTHORIZED_USER_CLIENT_SECRET",
							"AuthorizedUserRefreshToken": "$AUTHORIZED_USER_REFRESH_TOKEN"
						}
					},
					"BaseUrl": "$BASE_URL"
				}
			}
			EOF
		else
			err "Must set AUTHORIZED_USER_FILE or AUTHORIZED_USER_CLIENT_ID"
			return 10
		fi
	else
		err "Must set ACCOUNTS or ACCOUNT_NAME"
		return 11
	fi
}
