# Claude Skills Collection

A curated collection of custom skills for Claude that I find useful in my work. 

## About This Repository

This repository contains custom Claude skills designed to improve how Claude approaches different types of tasks. Each skill is a self-contained module that can be installed independently in Claude.ai or used via the Claude API or Claude Code

## What Are Claude Skills?

Claude skills are custom instructions that modify how Claude behaves in specific situations. They can:
- Trigger automatically based on conversation patterns
- Apply specialized reasoning frameworks
- Enforce structured thinking processes
- Add domain-specific knowledge and approaches

## Available Skills

### claude_deepthink

**Purpose:** Prevents automatic agreement or disagreement by enforcing deeper analysis and multi-perspective thinking.

**When it activates:**
- Confirmation-seeking questions ("Is X the best?")
- Leading statements ("Obviously A is better than B")
- Binary choice questions ("Which is better, X or Y?")
- Any situation prompting quick validation

**What it does:**
- Reframes questions to expose underlying concerns
- Presents multiple valid perspectives
- Identifies context-dependent factors
- Provides nuanced, well-reasoned recommendations

**Use case:** Get more thorough analysis of technical decisions, architectural choices, framework comparisons, and any situation where you want Claude to think critically rather than reflexively agree.

[View detailed documentation →](./claude_deepthink/README.md)

## Installation

### For Claude.ai (Web/Mobile Apps)

1. Navigate to the specific skill directory (e.g., `claude_deepthink`)
2. Create a ZIP file containing the skill's files (`Skill.md` and `README.md`)
3. Go to Claude.ai Settings > Capabilities > Skills
4. Click "Upload Skill" and select the ZIP file
5. Enable the skill

### For Claude API

Place the `Skill.md` file from each skill directory in your skills configuration according to your API integration setup. Consult the Claude API documentation for skill configuration details.

## Skill Structure

Each skill in this repository follows this structure:

```
skill_name/
├── Skill.md          # The skill definition (required for Claude)
└── README.md         # Documentation and usage examples
```

## Resources

- [Claude Skills Documentation](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)
- [Claude.ai](https://claude.ai)
- [Anthropic Research](https://www.anthropic.com/research)
