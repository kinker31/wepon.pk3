#!/bin/bash

FOLDS=("wepon_dev" "adonn_dev")
for folder in "${FOLDS[@]}"; do
	if [ -d "$folder" ]; then
		 (cd "$folder" && zip -r "../${folder}.pk3" ./*)
	else
		echo "Yo m8, folder missin'."
	fi
done