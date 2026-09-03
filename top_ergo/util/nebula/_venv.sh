# Copyright Gargantuan5k, 2026.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Shared venv-activation snippet. Source this, don't execute it:
#   source "$(dirname "${BASH_SOURCE[0]}")/_venv.sh"
#
# fusesoc/topgen/edalize all live in a project venv, not system Python —
# a fresh shell (no prior `source .../activate`) will not find them on
# PATH, which fails with a bare "command not found" that doesn't say why.

NEBULA_VENV="${NEBULA_VENV:-$HOME/.venvs/opentitan}"
if [ -z "${VIRTUAL_ENV:-}" ]; then
  if [ -f "$NEBULA_VENV/bin/activate" ]; then
    # shellcheck disable=SC1091
    source "$NEBULA_VENV/bin/activate"
  else
    echo "warning: no venv active and $NEBULA_VENV not found." \
         "fusesoc/topgen/edalize need to be installed in a venv" \
         "(Python 3.12 for topgen's libcst dep) — set NEBULA_VENV or" \
         "activate your own venv before running this script." >&2
  fi
fi
