#!/bin/bash

# exit when any command fails
set -e

function fail {
    printf '%s\n' "$1" >&2
    exit "${2-1}"
}

COMPOSER_JSON=$GITHUB_WORKSPACE/composer.json
COMPOSER_LOCK=$GITHUB_WORKSPACE/composer.lock

PACKAGE_JSON=$GITHUB_WORKSPACE/package.json
PACKAGE_LOCK=$GITHUB_WORKSPACE/package-lock.json

echo "COMPOSER Pre-Check files"
if [ -f "$COMPOSER_JSON" ]; then
    echo "$COMPOSER_JSON exists."

    if [ -f "$COMPOSER_LOCK" ]; then
      echo "Install symfony CLI"
      wget https://get.symfony.com/cli/installer -O - | bash

      echo "Start composer security check:"

      if /home/runner/.symfony/bin/symfony security:check | grep -q 'No packages have known vulnerabilities.'; then
          echo "COMPOSER - No packages have known vulnerabilities."
        else
          fail "COMPOSER - Found known vulnerabilities."
      fi

    else
      fail "DANGER! There is a $COMPOSER_JSON, but no $COMPOSER_LOCK!"
    fi
else
    echo "$COMPOSER_JSON does not exist. Skip this check."
fi

echo "NPM Pre-Check files"
if [ -f "$PACKAGE_JSON" ]; then
    echo "$PACKAGE_JSON exists."

    if [ -f "$PACKAGE_LOCK" ]; then
      echo "Start npm (prod) security audit:"

      if npm audit --production --audit-level=high | grep -q 'found 0 vulnerabilities'; then
          echo "NPM - No packages have known vulnerabilities."
        else
          fail "NPM - Found known vulnerabilities."
      fi

    else
      fail "DANGER! There is a $PACKAGE_JSON, but no $PACKAGE_LOCK!"
    fi
else
    echo "$PACKAGE_JSON does not exist. Skip this check."
fi

exit 0
