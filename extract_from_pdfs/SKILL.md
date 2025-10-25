# Extract Structured Data from Scientific PDFs

A comprehensive skill for extracting standardized data from scientific PDF literature and creating structured databases for research purposes.

## Overview

This skill guides you through a complete pipeline for:
1. Organizing PDF literature and metadata
2. Filtering relevant papers (optional)
3. Defining and extracting structured data
4. Validating and enriching data with external databases
5. Exporting to your preferred analysis framework

Based on proven workflows but generalized for any scientific domain.

---

## Quick Start

I'll help you set up a custom data extraction pipeline. First, let me understand your project:

### 1. Project Setup

**What is your research domain and what type of data do you want to extract?**

Examples:
- Flower visitor observations from ecology papers
- Chemical compound properties from chemistry literature
- Archaeological site characteristics
- Clinical trial outcomes
- Gene expression data

**Your answer:** {Please describe your domain and extraction goals}

---

### 2. Data Organization

**How are your PDFs currently organized?**

I'll help you choose the best approach based on Anthropic's latest recommendations:

#### Option A: Reference Manager Export (Recommended)
- Export from Zotero, Mendeley, EndNote, etc.
- Provides BibTeX/RIS with metadata + PDF links
- Best for: Literature review workflows

#### Option B: Directory with PDFs
- Organize PDFs in folders
- Extract metadata from filenames or DOIs
- Best for: Smaller collections, specific paper sets

#### Option C: URLs to PDFs
- Provide list of DOIs or URLs
- Auto-download with metadata
- Best for: Programmatic access

**Your current situation:** {Please describe}

---

### 3. PDF Processing Options

Based on Anthropic's 2025 best practices, I'll recommend one of these approaches:

#### Method 1: Direct Upload (base64)
- **Best for:** < 100 papers, < 100 pages each
- **Pros:** Simple, no external storage needed
- **Cons:** 32MB file size limit
- **Token cost:** ~1,500-3,000 tokens/page

#### Method 2: Files API
- **Best for:** Repeated queries on same documents
- **Pros:** Upload once, reuse across requests
- **Cons:** Requires API setup
- **Token cost:** Same as Method 1, but cacheable

#### Method 3: Chunked Processing
- **Best for:** Large PDFs (>100 pages), many documents
- **Pros:** No size limits, can use prompt caching
- **Cons:** More complex setup
- **Token cost:** Reduced by 90% with caching

**Based on your collection, I recommend:** {I'll suggest after you provide details}

---

### 4. Define Extraction Schema

Now, let's design what data to extract. I'll guide you through examples from your PDFs.

**Please provide 2-3 example PDFs so I can:**
1. Analyze their structure and content
2. Identify extractable data fields
3. Suggest appropriate data types
4. Design optimal prompts
5. Estimate token usage

**How to provide examples:**
- Path to local PDFs
- URLs to open-access papers
- DOIs I can fetch

---

### 5. Interactive Schema Design

After examining your examples, I'll ask detailed questions about:

#### Data Fields
- What information appears consistently?
- What's optional vs. required?
- What are the data types? (text, numbers, dates, lists, nested objects)
- What level of detail is needed?

#### Reasoning Requirements
- Does extraction require domain expertise?
- Are there ambiguous cases needing interpretation?
- Should I validate/standardize names (e.g., species, locations)?
- Any calculations or derived fields?

#### Quality Controls
- How to handle missing data?
- What makes a "complete" record?
- Any bias indicators to flag?

---

### 6. Model Selection & Token Estimation

Based on your schema, I'll recommend:

**Model Options:**
- **Claude 3.5 Sonnet**: Best balance of speed/accuracy/cost (recommended for most uses)
- **Claude 3 Opus**: Maximum accuracy for complex reasoning
- **Claude 3 Haiku**: Fast/cheap for simple extraction

**Processing Strategy:**
- Sequential vs. batch processing
- Use of prompt caching
- Filtering step (analyze abstracts first to reduce costs)

**Cost Estimation:**
I'll calculate:
- Average tokens per paper
- Total estimated cost for your collection
- Cost savings from filtering/caching

---

### 7. Validation & Enrichment

**Should I suggest external databases for validation?**

Based on your data type, I'll search for relevant APIs:

Examples:
- **Geography:** GeoNames, OpenStreetMap, Google Maps
- **Biological taxonomy:** GBIF, WoRMS, NCBI Taxonomy, World Flora Online
- **Chemistry:** PubChem, ChEMBL
- **Genes:** NCBI Gene, Ensembl
- **Clinical:** ClinicalTrials.gov
- **Publications:** CrossRef, PubMed

**Your validation needs:** {Please specify or say "suggest based on my data"}

---

### 8. Output Format

**What's your preferred analysis environment?**

I'll create export scripts for:
- [ ] Python (pandas DataFrame, SQLite, PostgreSQL)
- [ ] R (data.frame, RDS, database connections)
- [ ] CSV (universal compatibility)
- [ ] JSON (for web apps, APIs)
- [ ] Excel (for manual review)
- [ ] Other: {specify}

---

## Workflow Steps

Once we complete the setup, I'll generate a customized pipeline:

### Step 1: Organize Metadata
```bash
python templates/01_organize_metadata.py \
  --source {your_metadata_file} \
  --pdf-dir {pdf_directory} \
  --output metadata.json
```

### Step 2: Filter Papers (Optional)

**Choose your filtering backend:**

**Option A: Claude Haiku (Recommended - Fast & Cheap)**
```bash
python templates/02_filter_abstracts.py \
  --metadata metadata.json \
  --backend anthropic-haiku \
  --use-batches \
  --output filtered_papers.json
```
*Cost: ~$0.25 per million input tokens*

**Option B: Local Model via Ollama (FREE & Private)**
```bash
# Setup (one-time):
# 1. Install Ollama: https://ollama.com
# 2. Pull model: ollama pull llama3.1:8b
# 3. Start server: ollama serve

python templates/02_filter_abstracts.py \
  --metadata metadata.json \
  --backend ollama \
  --ollama-model llama3.1:8b \
  --output filtered_papers.json
```
*No cost, runs locally. Recommended models: llama3.1:8b, mistral:7b*

### Step 3: Extract Data
```bash
python templates/03_extract_from_pdfs.py \
  --metadata filtered_papers.json \
  --schema schema.json \
  --use-caching \
  --output raw_extractions.json
```

### Step 4: Repair & Validate JSON
```bash
python templates/04_repair_json.py \
  --input raw_extractions.json \
  --output cleaned_extractions.json
```

### Step 5: Validate with External APIs
```bash
python templates/05_validate_with_apis.py \
  --input cleaned_extractions.json \
  --apis {api_config.json} \
  --output validated_data.json
```

### Step 6: Export to Analysis Format
```bash
python templates/06_export_database.py \
  --input validated_data.json \
  --format {python|r|csv|json|excel} \
  --output final_database
```

---

## Validation & Quality Assurance (Optional but Recommended)

After running your extraction pipeline, validate its quality:

### Step 7: Prepare Validation Set
```bash
python templates/07_prepare_validation_set.py \
  --extraction-results cleaned_extractions.json \
  --schema schema.json \
  --sample-size 20 \
  --strategy stratified \
  --output validation_set.json
```

This creates a sample of papers for manual annotation. Sampling strategies:
- **random**: Random sample (good for overall quality)
- **stratified**: Sample by extraction characteristics (identifies weaknesses)
- **diverse**: Maximize diversity (comprehensive evaluation)

### Step 8: Manually Annotate
1. Open `validation_set.json` in a text editor
2. For each sampled paper, read the PDF
3. Fill in the `ground_truth` field with correct extraction
4. Add your name in `annotator` and date in `annotation_date`
5. Use `notes` for any ambiguous cases

### Step 9: Calculate Validation Metrics
```bash
python templates/08_calculate_validation_metrics.py \
  --annotations validation_set.json \
  --output validation_metrics.json \
  --report validation_report.txt
```

This calculates:
- **Precision**: Of extracted items, how many are correct?
- **Recall**: Of true items, how many were extracted?
- **F1 Score**: Harmonic mean of precision and recall
- **Per-field metrics**: Which fields are most/least accurate?

**Use these metrics to:**
- Identify weak points in your extraction prompts
- Iterate and improve your schema
- Compare different models (e.g., Haiku vs Sonnet vs Ollama)
- Report extraction quality in publications

**Recommended validation set size:**
- Small projects (<100 papers): 10-20 papers
- Medium projects (100-500 papers): 20-50 papers
- Large projects (>500 papers): 50-100 papers

---

## What I Need From You Now

To get started, please provide:

1. **Research domain and extraction goals** (1-2 sentences)
2. **How your PDFs are organized** (reference manager? directory? list?)
3. **Approximate collection size** (number of papers, average pages)
4. **2-3 example PDFs** (paths, URLs, or DOIs)
5. **Preferred analysis environment** (Python, R, other)

Once you provide this information, I'll:
- Search for the latest best practices specific to your domain
- Analyze your example PDFs
- Design a custom extraction schema through interactive Q&A
- Suggest appropriate validation databases
- Generate all necessary scripts with your specific parameters
- Estimate costs and processing time
- Create documentation for your specific workflow

**Ready to begin? Please provide the information above!**
