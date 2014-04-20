#!/usr/bin/env bash
cd vendor
tar -xzvf jruby-bin-1.7.10.tar.gz
cd jruby-1.7.10/bin
PATH=`pwd`:$PATH
echo $PATH
export PATH

gem install bundler
bundle install
