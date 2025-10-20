# BUSCO-based Phylogenomics - Technical Reference

Detailed technical reference for implementing phylogenomic workflows.

## Table of Contents

1. [Sample Naming Best Practices](#sample-naming-best-practices)
2. [BUSCO Lineage Datasets](#busco-lineage-datasets)
3. [Resource Recommendations](#resource-recommendations)
4. [Template Job Scripts](#template-job-scripts)
5. [Common Issues](#common-issues)
6. [Quality Control Guidelines](#quality-control-guidelines)
7. [Tool Citations](#tool-citations)

---

## Sample Naming Best Practices

**Sample names appear in your final phylogenetic trees**, so choose them carefully!

### Recommended Format

**`[ACCESSION]_[SPECIES_NAME]`**

Examples:
- `GCA000001735_Arabidopsis_thaliana`
- `GCF009858895_Apis_mellifera`
- `PRJNA12345_Drosophila_melanogaster_strain_w1118`

### Why This Format?

1. **Accession first** = Easy to trace back to original data
2. **Species name** = Readable in phylogenetic trees
3. **Underscore-separated** = Compatible with all phylogenetics software
4. **No spaces or special characters** = Prevents parsing errors

### Rules for Sample Names

**DO:**
- Use only letters, numbers, underscores, and hyphens
- Keep names reasonably short (<50 characters)
- Be consistent across your dataset
- Include strain/population info if relevant (e.g., `GCA123_Species_name_pop1`)

**DON'T:**
- Use spaces (use underscores instead)
- Use special characters: `()[]{}|<>@#$%^&*+=;:'",./\`
- Start with numbers (some tools don't like this)
- Use periods except for version numbers
- Make names too cryptic (will appear in publications!)

### Using the Rename Helper Script

The `scripts/rename_genomes.py` helper can assist with renaming:

```bash
# Create a template mapping file
python scripts/rename_genomes.py --create-template *.fasta > samples.tsv

# Edit samples.tsv to add meaningful names:
# GCA_000001735.2.fasta    GCA000001735_Arabidopsis_thaliana
# GCF_009858895.2.fasta    GCF009858895_Apis_mellifera

# Apply the mapping (with backup)
python scripts/rename_genomes.py --mapping samples.tsv

# Or use interactive mode
python scripts/rename_genomes.py --interactive *.fasta
```

### For NCBI Downloaded Genomes

When downloading from NCBI, genome files are typically in subdirectories like:
```
ncbi_dataset/data/GCA_000001735.2/GCA_000001735.2_genomic.fna
```

You'll need to:
1. Extract assembly accessions and organism names
2. Create meaningful sample names
3. Copy and rename files to working directory

Example workflow:
```bash
# List assemblies with organism names
for dir in ncbi_dataset/data/GCA_*; do
    acc=$(basename $dir)
    # Extract organism name from metadata
    echo "$acc"
done

# Create mapping file manually or with download_ncbi_genomes.py --list-only
```

---

## BUSCO Lineage Datasets

### General Lineages

- `eukaryota_odb10` - All eukaryotes (255 BUSCOs)
- `bacteria_odb10` - All bacteria (124 BUSCOs)
- `archaea_odb10` - All archaea (194 BUSCOs)

### Eukaryotic Kingdoms

- `metazoa_odb10` - Animals (954 BUSCOs)
- `viridiplantae_odb10` - Green plants (425 BUSCOs)
- `fungi_odb10` - Fungi (758 BUSCOs)

### Animals (Metazoa)

- `arthropoda_odb10` - Arthropods (1013 BUSCOs)
  - `insecta_odb10` - Insects (1367 BUSCOs)
    - `diptera_odb10` - Flies (3285 BUSCOs)
    - `hymenoptera_odb10` - Bees, wasps, ants (5991 BUSCOs)
    - `lepidoptera_odb10` - Moths, butterflies (5286 BUSCOs)
  - `arachnida_odb10` - Spiders, mites (2934 BUSCOs)
- `vertebrata_odb10` - Vertebrates (3354 BUSCOs)
  - `actinopterygii_odb10` - Ray-finned fish (3640 BUSCOs)
  - `mammalia_odb10` - Mammals (9226 BUSCOs)
  - `aves_odb10` - Birds (8338 BUSCOs)
- `mollusca_odb10` - Molluscs (5295 BUSCOs)
- `nematoda_odb10` - Roundworms (3131 BUSCOs)

### Plants (Viridiplantae)

- `eudicots_odb10` - Eudicots (2326 BUSCOs)
- `liliopsida_odb10` - Monocots (3278 BUSCOs)
- `embryophyta_odb10` - Land plants (1614 BUSCOs)

### Fungi

- `ascomycota_odb10` - Ascomycetes (1706 BUSCOs)
- `basidiomycota_odb10` - Basidiomycetes (1335 BUSCOs)

*For complete list, see: https://busco-data.ezlab.org/v5/data/lineages/*

---

## Resource Recommendations

### SLURM/PBS Job Resource Allocations

| Step | CPUs | RAM per CPU | Total RAM | Walltime | Notes |
|------|------|-------------|-----------|----------|-------|
| compleasm | 4 | 6 GB | 24 GB | 24h | Increase to 8-10 GB for large genomes (>2 Gbp) |
| MAFFT (per locus) | 1 | 4 GB | 4 GB | 24h | Can run as large array job |
| Aliscore | 1 | 4 GB | 4 GB | 24h | Array job |
| trimAl | 1 | 2 GB | 2 GB | 2h | Very fast |
| BMGE | 1 | 2 GB | 2 GB | 4h | Moderate speed |
| ClipKit | 1 | 2 GB | 2 GB | 2h | Very fast |
| IQ-TREE (gene) | 1 | 4 GB | 4 GB | 2h | Array job for all loci |
| IQ-TREE (concat) | 18-32 | 4 GB | 72-128 GB | 72h | Main phylogeny job |
| ASTRAL | 1 | 8 GB | 8 GB | <1h | Usually very fast |

### Scaling Guidelines

**Small dataset** (<20 genomes, <1000 loci):
- Can run on local machine
- Expect ~2-5 days total runtime

**Medium dataset** (20-50 genomes, 1000-3000 loci):
- Cluster recommended
- Expect ~3-7 days with parallelization

**Large dataset** (>50 genomes, >3000 loci):
- Cluster required
- Expect 1-2 weeks with good parallelization

---

## Template Job Scripts

### SLURM Array Template

```bash
#!/bin/bash
#SBATCH --job-name=JOB_NAME
#SBATCH --array=1-N
#SBATCH --cpus-per-task=NCPUS
#SBATCH --mem-per-cpu=MEMORY
#SBATCH --time=WALLTIME
#SBATCH --output=logs/%A_%a.JOBNAME.out
#SBATCH --error=logs/%A_%a.JOBNAME.err
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=YOUR_EMAIL

source ~/.bashrc
conda activate ENV_NAME

# Parse input file
input=$(sed -n "${SLURM_ARRAY_TASK_ID}p" input_list.txt)

# Run command
COMMAND ${input}
```

### PBS Array Template

```bash
#!/bin/bash
#PBS -N JOB_NAME
#PBS -t 1-N
#PBS -l nodes=1:ppn=NCPUS
#PBS -l mem=MEMORY
#PBS -l walltime=WALLTIME
#PBS -j oe
#PBS -m abe
#PBS -M YOUR_EMAIL

cd $PBS_O_WORKDIR
source ~/.bashrc
conda activate ENV_NAME

# Parse input file
input=$(sed -n "${PBS_ARRAYID}p" input_list.txt)

# Run command
COMMAND ${input}
```

### Local Sequential Template

```bash
#!/bin/bash
# Sequential execution for local machine

source ~/.bashrc
conda activate ENV_NAME

while read input; do
  echo "Processing ${input}..."
  COMMAND ${input}
done < input_list.txt

echo "All jobs complete"
```

---

## Common Issues

### Problem: compleasm runs out of memory

**Solution:**
- Increase `--mem-per-cpu` to 8 GB or 10 GB
- Some large/complex genomes need more RAM

### Problem: IQ-TREE stalls or runs extremely slowly

**Solution:**
- Add `-safe` flag (enables safe numerical mode, slower but more stable)
- Reduce number of threads if on shared system
- Check for very long branches or problematic sequences

### Problem: Array job exceeds cluster limits

**Solution:**
- Split into batches (e.g., if limit is 1000, run arrays 1-1000, 1001-2000, etc.)
- Example: `#SBATCH --array=1-1000%50` (runs 1000 jobs, max 50 concurrent)

### Problem: Missing orthologs in some genomes

**Solution:**
- This is normal and expected
- FASconCAT and IQ-TREE handle missing data automatically
- If >20% orthologs missing, consider genome quality issues

### Problem: Alignment looks poor/misaligned

**Solution:**
- Visualize with AliView or Jalview
- MAFFT L-INS-i is accurate but slow; for very divergent sequences, try E-INS-i
- Consider stricter trimming parameters
- Very divergent sequences may not be suitable for phylogenomics

### Problem: Gene trees conflict with concatenation tree

**Solution:**
- This is common and expected (incomplete lineage sorting, gene flow)
- ASTRAL species tree accounts for discordance
- Compare both trees and branch support values
- Look for systematic vs. random conflicts

### Problem: Low bootstrap/posterior support values

**Solution:**
- Check alignment quality
- Try more stringent trimming
- Evaluate locus informativeness (some may be uninformative)
- Consider rapid diversification or conflicting signal
- More data doesn't always help if signal quality is poor

---

## Quality Control Guidelines

### Genome Completeness Assessment

**Excellent** (>95% complete BUSCOs):
- Highly complete genomes
- Retain for phylogenomics
- Expected to contribute many orthologs

**Good** (90-95% complete):
- Generally acceptable
- May be missing some loci
- Retain unless other quality concerns

**Acceptable** (85-90% complete):
- Marginal quality
- Will have more missing orthologs
- Consider case-by-case based on biological importance

**Questionable** (70-85% complete):
- Poor completeness
- May introduce noise
- Recommend excluding unless scientifically critical

**Poor** (<70% complete):
- Very incomplete
- Strong recommend to exclude
- Likely contaminated, fragmented, or poor assembly

### Fragmentation and Duplication

**Fragmented BUSCOs:**
- <5%: Excellent
- 5-10%: Good
- >10%: Indicates assembly fragmentation issues

**Duplicated BUSCOs:**
- <2%: Excellent
- 2-5%: Good (may indicate recent WGD or heterozygosity)
- >10%: Likely contamination or assembly issues

---

## Tool Citations

### Required Citations

**compleasm:**
Huang, N., & Li, H. (2023). compleasm: a faster and more accurate reimplementation of BUSCO. *Bioinformatics*, 39(10), btad595.
https://doi.org/10.1093/bioinformatics/btad595

**BUSCO (if used instead of compleasm):**
Manni, M., Berkeley, M. R., Seppey, M., Simão, F. A., & Zdobnov, E. M. (2021). BUSCO update: novel and streamlined workflows along with broader and deeper phylogenetic coverage for scoring of eukaryotic, prokaryotic, and viral genomes. *Molecular Biology and Evolution*, 38(10), 4647-4654.

**MAFFT:**
Katoh, K., & Standley, D. M. (2013). MAFFT multiple sequence alignment software version 7: improvements in performance and usability. *Molecular Biology and Evolution*, 30(4), 772-780.

**IQ-TREE:**
Minh, B. Q., Schmidt, H. A., Chernomor, O., Schrempf, D., Woodhams, M. D., von Haeseler, A., & Lanfear, R. (2020). IQ-TREE 2: new models and efficient methods for phylogenetic inference in the genomic era. *Molecular Biology and Evolution*, 37(5), 1530-1534.

**ASTRAL:**
Zhang, C., Rabiee, M., Sayyari, E., & Mirarab, S. (2018). ASTRAL-III: polynomial time species tree reconstruction from partially resolved gene trees. *BMC Bioinformatics*, 19(6), 153.

### Trimming Tool Citations

**Aliscore/ALICUT:**
Kück, P., Meusemann, K., Dambach, J., Thormann, B., von Reumont, B. M., Wägele, J. W., & Misof, B. (2010). Parametric and non-parametric masking of randomness in sequence alignments can be improved and leads to better resolved trees. *Frontiers in Zoology*, 7(1), 10.

**trimAl:**
Capella-Gutiérrez, S., Silla-Martínez, J. M., & Gabaldón, T. (2009). trimAl: a tool for automated alignment trimming in large-scale phylogenetic analyses. *Bioinformatics*, 25(15), 1972-1973.

**BMGE:**
Criscuolo, A., & Gribaldo, S. (2010). BMGE (Block Mapping and Gathering with Entropy): a new software for selection of phylogenetic informative regions from multiple sequence alignments. *BMC Evolutionary Biology*, 10(1), 210.

**ClipKit:**
Steenwyk, J. L., Buida III, T. J., Li, Y., Shen, X. X., & Rokas, A. (2020). ClipKIT: a multiple sequence alignment trimming software for accurate phylogenomic inference. *PLOS Biology*, 18(12), e3001007.

### Software Download Links

- **compleasm:** https://github.com/huangnengCSU/compleasm
- **BUSCO:** https://busco.ezlab.org/
- **MAFFT:** https://mafft.cbrc.jp/alignment/software/
- **IQ-TREE:** http://www.iqtree.org/
- **ASTRAL:** https://github.com/smirarab/ASTRAL
- **trimAl:** http://trimal.cgenomics.org/
- **BMGE:** https://bioweb.pasteur.fr/packages/pack@BMGE@1.12
- **ClipKit:** https://github.com/JLSteenwyk/ClipKIT
- **FASconCAT:** https://www.zfmk.de/en/research/research-centres-and-groups/fasconcat-g
- **NCBI Datasets:** https://www.ncbi.nlm.nih.gov/datasets/

---

## Docker Container Specification

If using Docker, here's a complete Dockerfile with all tools:

```dockerfile
FROM mambaorg/micromamba:latest

LABEL maintainer="Bruno de Medeiros <Field Museum>"
LABEL description="Complete environment for BUSCO-based phylogenomics"

# Install all phylogenomics tools
RUN micromamba install -y -n base -c conda-forge -c bioconda \
    compleasm \
    busco \
    mafft \
    trimal \
    bmge \
    clipkit \
    iqtree \
    ncbi-datasets-cli \
    python=3.9 \
    biopython \
    perl \
    openjdk \
    wget \
    unzip \
    && micromamba clean --all --yes

# Set working directory
WORKDIR /data

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
CMD ["/bin/bash"]
```

Build and run:
```bash
docker build -t phylogenomics:latest .
docker run -v $(pwd):/data -it phylogenomics:latest
```

---

*This reference guide complements the main BUSCO phylogenomics skill and provides detailed technical specifications for implementation.*
