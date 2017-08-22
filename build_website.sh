#!/usr/bin/env bash

echo "Building website .."

# exit upon failed command and use of undeclared variables
set -e -u

function set_this_up {
  if [ "$TRAVIS_BRANCH" != "master" ]
  then
    echo "This commit was made against the $TRAVIS_BRANCH branch and not the master branch. Exit."
    exit 0
  fi
  if [ -z ${GH_TOKEN+x} ]
  then
    echo "GH_TOKEN was not set, so this is probably a fork. Exit."
    exit 0
  fi
}

function install_miniconda_with_jupyter {
  # we need jupyter to convert the notebooks, therefore use miniconda
  mkdir -p $HOME/conda_dl || true
  cd $HOME/conda_dl
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
  bash miniconda.sh -b -p $HOME/miniconda
  export PATH="$HOME/miniconda/bin:$PATH"
  hash -r
  conda config --set always_yes yes --set changeps1 no
  conda update -q conda
  conda info -a
  conda install jupyter
  cd -
}

function get_tutorials {
  cd $HOME
  git clone "https://github.com/readdy/readdy_tutorials.git"
}

# only to build the doxygen manual
function get_readdy {
  cd $HOME
  git clone "https://github.com/readdy/readdy.git"
}

function convert_tutorials {
  cd $HOME/readdy_tutorials
  # remove the github repo utils so they don't end up in the website output
  rm .gitignore || true
  rm README.md || true
  rm -rf .git/ || true

  ./convert_tutorials.py "."

  rm *.ipynb

  cd -
}

function make_reference_doc {
  mkdir -p $HOME/reference || true
  cd $HOME/reference
  # cant reliably determine cpu count in a docker container,
  # therefore fix this value.
  CPU_COUNT=2
  cmake $HOME/readdy -DREADDY_GENERATE_DOCUMENTATION_TARGET_ONLY:BOOL=ON
  make doc
  cd -
}

function make_website {
  # setup jekyll via bundler
  cd $TRAVIS_BUILD_DIR/readdy_documentation
  bundle install
  # insert the reference documentation
  cp -r $HOME/reference/docs/html/* reference_manual/
  # insert the converted tutorials
  mkdir _tutorials || true
  cp -r $HOME/readdy_tutorials/* _tutorials/
  # build
  bundle exec jekyll build
  cd _site
  rm Gemfile Gemfile.lock
}

function setup_output_repo {
  cd $TRAVIS_BUILD_DIR/readdy_documentation/_site
  # this is already pure html, no further jekyll action needed by github
  touch .nojekyll
  git init
  git config user.name "Christoph Froehner"
  git config user.email "chrisfroe@users.noreply.github.com"
  git remote add upstream "https://$GH_TOKEN@github.com/readdy/readdy_documentation.git" > /dev/null 2>&1
  git fetch upstream
  git checkout --orphan workbranch
  git reset --hard
  cd -
}

function deploy {
  cd $TRAVIS_BUILD_DIR/readdy_documentation/_site/
  touch .
  git add -A .
  git commit -m "github pages"
  git push -q -f upstream workbranch:gh-pages > /dev/null 2>&1
}

set_this_up
install_miniconda_with_jupyter
get_tutorials
convert_tutorials
get_readdy
make_reference_doc
make_website
setup_output_repo
deploy
