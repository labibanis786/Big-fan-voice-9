#!/usr/bin/env sh
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"
exec ./gradlew "$@"