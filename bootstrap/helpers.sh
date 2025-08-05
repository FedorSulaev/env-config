#!/usr/bin/env bash
set -eo pipefail

# UX helpers
function red() {
    echo -e "\x1B[31m[!] $1 \x1B[0m"
    if [ -n "${2-}" ]; then
        echo -e "\x1B[31m[!] $($2) \x1B[0m"
    fi
}

function green() {
    echo -e "\x1B[32m[+] $1 \x1B[0m"
    if [ -n "${2-}" ]; then
        echo -e "\x1B[32m[+] $($2) \x1B[0m"
    fi
}

function blue() {
    echo -e "\x1B[34m[*] $1 \x1B[0m"
    if [ -n "${2-}" ]; then
        echo -e "\x1B[34m[*] $($2) \x1B[0m"
    fi
}

function yellow() {
    echo -e "\x1B[33m[*] $1 \x1B[0m"
    if [ -n "${2-}" ]; then
        echo -e "\x1B[33m[*] $($2) \x1B[0m"
    fi
}
