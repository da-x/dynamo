#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2024-2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Patch vLLM source before wheel build.
# Location: container/deps/vllm/patch-vllm.sh
#
# This script runs inside the Docker build in the framework stage,
# with working directory set to the vLLM source tree ($INSTALLATION_DIR/vllm)
# and the virtual environment already activated.

set -euo pipefail

VLLM_SRC_DIR="$(pwd)"
echo "  Patching vLLM source at: ${VLLM_SRC_DIR}"

# block_pool: sort the list of allocated free blocks
#
# Sorting the blocks returned from the free list increases the chance
# that blocks corresponding to the same request (and therefore KV cache
# content) will also be sequential in device memory. This helps offload
# engines that write out KV cache to file with a smaller scatter-gather
# vector, increasing IO size and offload throughput.
sed -i '/ret: list\[KVCacheBlock\] = self.free_block_queue.popleft_n(num_blocks)/a\        ret.sort(key=lambda block: block.block_id)' ${VLLM_SRC_DIR}/vllm/v1/core/block_pool.py

echo "  vLLM patching complete"
