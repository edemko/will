#!/bin/sh
set -e

service sshd status | grep -Fq 'Active: active (running)'
