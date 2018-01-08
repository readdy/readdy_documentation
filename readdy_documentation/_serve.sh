#!/usr/bin/env bash
bundle exec jekyll serve -d $(pwd)/build --trace --config _config.yml,_config_dev.yml --host localhost
