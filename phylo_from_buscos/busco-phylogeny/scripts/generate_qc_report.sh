#!/bin/bash
# Quality control report generator for compleasm results
#
# Usage: bash generate_qc_report.sh [output_file.csv]
#
# Author: Bruno de Medeiros (Field Museum)
# Based on tutorials by Paul Frandsen (BYU)

OUTPUT_FILE="${1:-qc_report.csv}"

echo "Genome,Complete_SCO,Fragmented,Duplicated,Missing,Completeness(%)" > "${OUTPUT_FILE}"

count=0
for dir in *_compleasm; do
  if [ ! -d "${dir}" ]; then
    continue
  fi

  genome=$(basename "${dir}" _compleasm)
  summary="${dir}/summary.txt"

  if [ -f "${summary}" ]; then
    # Parse completeness statistics
    complete=$(grep "Complete" "${summary}" | head -1 | awk '{print $2}')
    fragmented=$(grep "Fragmented" "${summary}" | awk '{print $2}')
    duplicated=$(grep "Duplicated" "${summary}" | awk '{print $2}')
    missing=$(grep "Missing" "${summary}" | awk '{print $2}')

    # Calculate completeness percentage
    if command -v bc &> /dev/null; then
      completeness=$(echo "scale=2; ${complete} / (${complete} + ${fragmented} + ${missing}) * 100" | bc)
    else
      # Fallback if bc not available
      completeness=$(awk "BEGIN {printf \"%.2f\", ${complete} / (${complete} + ${fragmented} + ${missing}) * 100}")
    fi

    echo "${genome},${complete},${fragmented},${duplicated},${missing},${completeness}" >> "${OUTPUT_FILE}"
    count=$((count + 1))
  else
    echo "Warning: Summary file not found for ${genome}" >&2
  fi
done

if [ ${count} -eq 0 ]; then
  echo "Error: No compleasm output directories found (*_compleasm)" >&2
  exit 1
fi

echo "QC report generated: ${OUTPUT_FILE}"
echo "Genomes analyzed: ${count}"
