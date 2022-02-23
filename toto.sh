#!/bin/bash
echo '$0:' $0
echo 'Script stored at:' ${0%/*}
cd "${0%/*}"
pwd
