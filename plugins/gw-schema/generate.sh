#!/bin/bash

GODWOKEN_REF=$GODWOKEN_GIT_CHECKOUT # import env var from .build.mode.env
ROOT_DIR=$PWD
TMP_DIR=$PWD/tmp
SCHEMAS_DIR=$PWD/schemas

download(){
  curl -L https://raw.githubusercontent.com/nervosnetwork/godwoken/$GODWOKEN_REF/crates/types/schemas/$1.mol -o $TMP_DIR/$1.mol
}

generate(){
    moleculec --language - --schema-file $TMP_DIR/$1.mol --format json > $TMP_DIR/$1.json
    ./molecule-es/moleculec-es -hasBigInt -inputFile $TMP_DIR/$1.json -outputFile $SCHEMAS_DIR/$1.esm.js -generateTypeScriptDefinition
    rollup -f umd -i $SCHEMAS_DIR/$1.esm.js -o $SCHEMAS_DIR/$1.js --name $2
    mv $SCHEMAS_DIR/$1.esm.d.ts $SCHEMAS_DIR/$1.d.ts
    mv $TMP_DIR/$1.json $SCHEMAS_DIR/$1.json
}

rename_godwoken(){
  for i in ./schemas/godwoken.* ; do mv "$i" "${i/godwoken/index}" ; done
}


run(){
  # require moleculec 0.7.2
  MOLC=moleculec
  MOLC_VERSION=0.7.2
  if [ ! -x "$(command -v "${MOLC}")" ] \
      || [ "$(${MOLC} --version | awk '{ print $2 }' | tr -d ' ')" != "${MOLC_VERSION}" ]; then \
    echo "Require moleculec v0.7.2, please run 'cargo install moleculec --locked --version 0.7.2' to install."; \
  fi

  # download molecylec-es, must be v0.3.1
  DIR=./molecule-es
  mkdir -p $DIR
  FILENAME=moleculec-es_0.3.1_$(uname -s)_$(uname -m).tar.gz
  curl -L https://github.com/nervosnetwork/moleculec-es/releases/download/0.3.1/${FILENAME} -o ${DIR}/${FILENAME}
  tar xzvf $DIR/$FILENAME -C $DIR

  # install rollup if needed
  ROLLUP=rollup
  if [ ! -x "$(command -v "${ROLLUP}")" ]; then
    npm install -g rollup
  fi

  mkdir -p $TMP_DIR
  mkdir -p $SCHEMAS_DIR

  echo "download mol from $GODWOKEN_GIT_CHECKOUT";
  
  download "blockchain"
  download "godwoken"
  download "store"

  generate "godwoken" "Godwoken"
  rename_godwoken

  rm -rf $TMP_DIR
  rm -rf $DIR
}

# start
run
