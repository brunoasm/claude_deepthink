# B. de Medeiros' Claude Skills Collection

A curated collection of custom skills for Claude that I find useful in my work. 

## About This Repository

This repository contains custom Claude skills designed to improve how Claude approaches different types of tasks. Each skill is a self-contained module that can be installed independently in Claude.ai or used via the Claude API or Claude Code.

### Anthropic Official Skills

The `anthropic-skills/` directory contains the official skills repository from Anthropic as a git submodule. This includes:
- **skill-creator**: A meta-skill that helps you create new custom skills
- Other official example skills and templates

To clone this repository with the submodule:
```bash
git clone --recurse-submodules <repository-url>
```

If you've already cloned without submodules:
```bash
git submodule update --init --recursive
```

## What Are Claude Skills?

Claude skills are custom instructions that modify how Claude behaves in specific situations. They can:
- Trigger automatically based on conversation patterns
- Apply specialized reasoning frameworks
- Enforce structured thinking processes
- Add domain-specific knowledge and approaches

## Available Skills

### General Skills

#### think-deeply
Enforces deeper analysis and multi-perspective thinking instead of automatic agreement/disagreement. Activates on confirmation-seeking questions, leading statements, and binary choices to provide nuanced, well-reasoned recommendations.

[View detailed documentation →](./think_deeply/README.md)

#### extract-from-pdfs
Complete pipeline for extracting structured data from scientific PDFs using Claude's vision capabilities. Supports metadata organization from BibTeX/RIS/directories, abstract filtering with local models (Ollama) or Claude Haiku/Sonnet, PDF data extraction, JSON repair, external API validation (GBIF, WFO, GeoNames, PubChem, NCBI), and export to Python/R/CSV/Excel/SQLite. Includes validation workflow with precision/recall metrics for quality assurance.

**Key Features:**
- 8-step pipeline from PDF to validated database
- Cost options: FREE (local Ollama), cheap (Haiku ~$0.25/M tokens), or accurate (Sonnet)
- External database validation for taxonomy, geography, chemistry
- Validation metrics (precision, recall, F1) with stratified sampling
- Export to multiple formats with ready-to-use loading scripts

[View detailed documentation →](./extract_from_pdfs/README.md)

### Bioinformatics Skills

#### phylo_from_buscos
Generates complete phylogenomic workflows from genome assemblies using BUSCO/compleasm-based single-copy orthologs. Supports NCBI accessions, multiple scheduler types (SLURM, PBS, cloud, local), and produces both concatenated and coalescent phylogenies with quality control.

[View detailed documentation →](./phylo_from_buscos/README.md)

#### biogeobears
Sets up phylogenetic biogeographic analyses using BioGeoBEARS in R. Validates and reformats input files (phylogenetic tree and geographic distribution data), generates organized analysis folders with RMarkdown scripts, guides parameter selection, and produces publication-ready visualizations of ancestral range reconstructions. Compares multiple biogeographic models (DEC, DIVALIKE, BAYAREALIKE with/without founder-event speciation).

[View detailed documentation →](./biogeobears/README.md)

## Installation

### For Claude Code (Recommended)

#### Install All Plugins

Install the entire marketplace with both plugin collections:

```bash
/plugin marketplace add brunoasm/my_claude_skills
/plugin install general-skills@brunoasm/my_claude_skills
/plugin install bioinfo-skills@brunoasm/my_claude_skills
```

#### Install Individual Plugins

Install only the plugins you need:

**For general skills only:**
```bash
/plugin marketplace add brunoasm/my_claude_skills
/plugin install general-skills@brunoasm/my_claude_skills
```

**For bioinformatics skills only:**
```bash
/plugin marketplace add brunoasm/my_claude_skills
/plugin install bioinfo-skills@brunoasm/my_claude_skills
```

#### Install from Local Clone

```bash
git clone https://github.com/brunoasm/my_claude_skills.git
cd my_claude_skills
/plugin marketplace add .
/plugin install general-skills@.
/plugin install bioinfo-skills@.
```

All installed skills will be automatically available in Claude Code.

### For Claude.ai (Web/Mobile Apps)

1. Go to [releases](https://github.com/brunoasm/my_claude_skills/releases) and download the zip file for the desired skill.
3. Go to Claude.ai Settings > Capabilities > Skills
4. Click "Upload Skill" and select the ZIP file
5. Enable the skill

### For Claude API

Download and uncompress the desired skill zip file from [releases](https://github.com/brunoasm/my_claude_skills/releases).

Place the `SKILL.md` file and associated files from each skill directory in your skills configuration according to your API integration setup. Consult the Claude API documentation for skill configuration details.

## Skill Structure

Each skill in this repository follows this minimal structure:

```
skill_name/
├── SKILL.md          # The skill definition (required for Claude)
└── README.md         # Documentation and usage examples
```

Other accesoty files may be available for each skill (e. g. scripts, detailed references, etc)

## Resources

- [Claude Skills Documentation](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)
- [Claude.ai](https://claude.ai)
- [Anthropic Research](https://www.anthropic.com/research)
