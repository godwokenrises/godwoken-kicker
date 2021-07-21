PROJECT_DIR='/code';
ENTRY_DIR=${PROJECT_DIR}/docker/gen-godwoken-schema

moleculec -V

mkdir -p ${ENTRY_DIR}/schemas

moleculec --language - --schema-file ${PROJECT_DIR}/packages/godwoken/crates/types/schemas/blockchain.mol --format json > ${ENTRY_DIR}/schemas/blockchain.json
moleculec --language - --schema-file ${PROJECT_DIR}/packages/godwoken/crates/types/schemas/godwoken.mol --format json > ${ENTRY_DIR}/schemas/godwoken.json
moleculec --language - --schema-file ${PROJECT_DIR}/packages/godwoken/crates/types/schemas/store.mol --format json > ${ENTRY_DIR}/schemas/store.json

${ENTRY_DIR}/moleculec-es -generateTypeScriptDefinition -hasBigInt -inputFile ${ENTRY_DIR}/schemas/blockchain.json -outputFile ${ENTRY_DIR}/schemas/blockchain.esm.js
${ENTRY_DIR}/moleculec-es -generateTypeScriptDefinition -hasBigInt -inputFile ${ENTRY_DIR}/schemas/godwoken.json -outputFile ${ENTRY_DIR}/schemas/godwoken.esm.js
${ENTRY_DIR}/moleculec-es -generateTypeScriptDefinition -hasBigInt -inputFile ${ENTRY_DIR}/schemas/store.json -outputFile ${ENTRY_DIR}/schemas/store.esm.js

# rollup to pack esm file
npm install -g rollup
rollup -f umd -i ${ENTRY_DIR}/schemas/blockchain.esm.js -o ${ENTRY_DIR}/schemas/blockchain.js --name CKBCore
rollup -f umd -i ${ENTRY_DIR}/schemas/godwoken.esm.js -o ${ENTRY_DIR}/schemas/godwoken.js --name GodwokenCore
rollup -f umd -i ${ENTRY_DIR}/schemas/store.esm.js -o ${ENTRY_DIR}/schemas/store.js --name GodwokenStoreCore

echo 'generated. '

#cp -r ${ENTRY_DIR}/schemas ${PROJECT_DIR}/godwoken-polyman/packages/godwoken/

echo 'done. '
