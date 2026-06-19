#!/usr/bin/env bash
# Usage: ./run_alu.sh [A] [B] [--gui]

set -e

GUI_MODE=0
ARGS=()
for arg in "$@"; do
    if [ "$arg" == "--gui" ] || [ "$arg" == "-g" ]; then
        GUI_MODE=1
    else
        ARGS+=("$arg")
    fi
done

if ! command -v vlog &> /dev/null; then
    for candidate in /opt/modelsim/linuxaloem /opt/modelsim/bin /opt/modelsim_ase/linux /opt/intelFPGA/modelsim_ase/linuxaloem; do
        if [ -x "$candidate/vlog" ]; then
            export PATH="$PATH:$candidate"
            break
        fi
    done
fi

if ! command -v vlog &> /dev/null; then
    echo "Error: vlog not found. Find it with: find /opt -iname vlog 2>/dev/null"
    echo "Then: export PATH=\$PATH:<directory containing vlog>"
    exit 1
fi

if [ -n "${ARGS[0]}" ] && [ -n "${ARGS[1]}" ]; then
    A_VAL="${ARGS[0]}"
    B_VAL="${ARGS[1]}"
else
    read -rp "Enter A (signed 8-bit, -128 to 127): " A_VAL
    read -rp "Enter B (signed 8-bit, -128 to 127): " B_VAL
fi

echo "Compiling..."
vlib -quiet work 2>/dev/null || true
vlog -quiet src/*.sv tb/alu_tb.sv

if [ "$GUI_MODE" -eq 1 ]; then
    echo "Launching ModelSim GUI with A=$A_VAL B=$B_VAL ..."
    vsim -voptargs="+acc" work.alu_tb +A="$A_VAL" +B="$B_VAL" \
         -do "add wave -r /alu_tb/*; run -all"
else
    echo "Running with A=$A_VAL B=$B_VAL ..."
    vsim -c work.alu_tb -do "run -all; quit" +A="$A_VAL" +B="$B_VAL"
fi