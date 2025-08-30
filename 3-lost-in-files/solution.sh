#!/usr/bin/env bash
scan() {
	(
		cd "$(dirname "$1")"
		file=$(basename "$1")
		dir="$file.extracted"
		mkdir "$dir"
		(
			cd "$dir"
			tar -xf "../$file"
			grep -rh "^Answer: "
			while IFS= read -r -d '' -u 9
			do
				scan "$REPLY"
			done 9< <( find . -type f -name '*.tar.gz' -exec printf '%s\0' {} + )
		)
		rm -rf "$dir"
	)
}

scan "$1"
