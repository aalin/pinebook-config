#!/bin/bash

step=10
opts=--exponent=2

case $1 in
  up)
    brightnessctl $opts set +$step%
  ;;
  down)
    brightnessctl $opts set $step%-
  ;;
esac
