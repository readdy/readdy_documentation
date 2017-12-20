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
  conda install -q jupyter
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

function get_assets {
  cd $TRAVIS_BUILD_DIR/readdy_documentation/assets
  wget -P ./videos/ https://userpage.fu-berlin.de/chrisfr/readdy_website/assets/videos/logo.webm
  wget -P ./videos/ https://userpage.fu-berlin.de/chrisfr/readdy_website/assets/videos/logo.mp4
  cd -
}

function convert_tutorials {
  cd $HOME/readdy_tutorials
  # remove the github repo utils so they don't end up in the website output
  rm .gitignore || true
  rm README.md || true
  rm -rf .git/ || true
  rm -rf utils/ || true

  cp $TRAVIS_BUILD_DIR/convert_tutorials.py "."
  ./convert_tutorials.py "./demonstration"
  ./convert_tutorials.py "./validation"
  ./convert_tutorials.py "./benchmark"

  rm ./demonstration/*.ipynb
  rm ./validation/*.ipynb
  rm ./benchmark/*.ipynb

  cd -
}

function make_reference_doc {
  mkdir -p $HOME/reference || true
  cd $HOME/reference
  # cant reliably determine cpu count in a docker container,
  # therefore fix this value.
  CPU_COUNT=2
  cmake $HOME/readdy -DREADDY_GENERATE_DOCUMENTATION_TARGET_ONLY:BOOL=ON
  echo "making doc"
  2>/dev/null 1>/dev/null make doc &
  echo "done with exit code $?"
  cd -
}

function make_website {
  # setup jekyll via bundler
  cd $TRAVIS_BUILD_DIR/readdy_documentation
  bundle install
  # insert the reference documentation
  # cp -r $HOME/reference/docs/html/* reference_manual/
  # insert the converted tutorials
  mkdir _demonstration || true
  mkdir _validation || true
  mkdir _benchmark || true
  cp -r $HOME/readdy_tutorials/demonstration/* _demonstration/
  cp -r $HOME/readdy_tutorials/validation/* _validation/
  cp -r $HOME/readdy_tutorials/benchmark/* _benchmark/
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
  git remote add upstream "https://$GH_TOKEN@github.com/readdy/readdy.github.io.git" > /dev/null 2>&1
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
  git push -q -f upstream workbranch:master > /dev/null 2>&1
}

set_this_up
install_miniconda_with_jupyter
get_tutorials
convert_tutorials
get_readdy
get_assets
# make_reference_doc
make_website
setup_output_repo
deploy
