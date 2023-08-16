#/bin/bash
#

time oc-mirror --config imageset-config-test.yaml file://mirror

#oc mirror -v 9 --from=mirror/mirror_seq1_000000.tar docker://localhost:5000

