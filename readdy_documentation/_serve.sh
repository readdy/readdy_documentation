#!/usr/bin/env bash
bundle exec jekyll serve -d $(pwd)/build --incremental --trace --config _config.yml,_config_dev.yml --host 0.0.0.0
