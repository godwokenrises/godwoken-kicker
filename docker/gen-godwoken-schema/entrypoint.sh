PROJECT_DIR='/code';
ENTRY_DIR=${PROJECT_DIR}/docker/gen-godwoken-schema

moleculec -V

moleculec --language - --schema-file ${PROJECT_DIR}/godwoken/crates/types/schemas/blockchain.mol --format json > ${ENTRY_DIR}/schemas/blockchain.json
moleculec --language - --schema-file ${PROJECT_DIR}/godwoken/crates/types/schemas/godwoken.mol --format json > ${ENTRY_DIR}/schemas/godwoken.json
moleculec --language - --schema-file ${PROJECT_DIR}/godwoken/crates/types/schemas/store.mol --format json > ${ENTRY_DIR}/schemas/store.json

${ENTRY_DIR}/moleculec-es -generateTypeScriptDefinition -hasBigInt -inputFile ${ENTRY_DIR}/schemas/blockchain.json -outputFile ${ENTRY_DIR}/schemas/blockchian.js
${ENTRY_DIR}/moleculec-es -generateTypeScriptDefinition -hasBigInt -inputFile ${ENTRY_DIR}/schemas/godwoken.json -outputFile ${ENTRY_DIR}/schemas/godwoken.js
${ENTRY_DIR}/moleculec-es -generateTypeScriptDefinition -hasBigInt -inputFile ${ENTRY_DIR}/schemas/store.json -outputFile ${ENTRY_DIR}/schemas/store.js

${ENTRY_DIR}/moleculec-es -inputFile ${ENTRY_DIR}/schemas/blockchain.json -outputFile ${ENTRY_DIR}/schemas/blockchian.esm.js
${ENTRY_DIR}/moleculec-es -inputFile ${ENTRY_DIR}/schemas/godwoken.json -outputFile ${ENTRY_DIR}/schemas/godwoken.esm.js
${ENTRY_DIR}/moleculec-es -inputFile ${ENTRY_DIR}/schemas/store.json -outputFile ${ENTRY_DIR}/schemas/store.esm.js

echo 'generated. '

cp -r ${ENTRY_DIR}/schemas ${PROJECT_DIR}/godwoken-examples/packages/godwoken/

echo 'done. '