#!/bin/bash -e

# Allow user supplied pre userdata code
${pre_userdata}

sed -i '/^KUBELET_EXTRA_ARGS=/a KUBELET_EXTRA_ARGS+=" ${kubelet_extra_args}"' /etc/eks/bootstrap.sh
