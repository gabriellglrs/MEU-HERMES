---
name: technical-content-review
description: "Review technical educational content for clarity and safety."
version: 1.0.0
author: Hermes Agent
category: research
---

# Technical Content Review

This skill provides a workflow for reviewing technical educational content (like learning paths, tutorials, courses) to ensure it is clear, safe, effective, and follows good instructional design principles.

## When to Use This

Use this skill when reviewing any technical educational material, especially hands-on learning paths for fields like cybersecurity, programming, or system administration where safety and proper progression are critical.

## Workflow

### 1. Initial Scan
- Read through the entire content to understand the scope, target audience, and learning objectives
- Note the overall structure and progression
- Identify any prerequisites stated or implied

### 2. Detailed Section-by-Section Review
For each section/module/chapter:

**a. Learning Objectives Check**
- Verify objectives are specific, measurable, achievable, relevant, and time-bound (SMART)
- Ensure they describe what the learner will be able to DO, not just what they'll know

**b. Prerequisites Validation**
- Confirm all required prior knowledge/tools are explicitly listed
- Check that prerequisites match what's actually assumed in the section
- Flag any gaps where assumed knowledge isn't covered in previous sections

**c. Safety & Ethics Review (Critical for Offensive Security)**
- If content covers scanning, exploitation, penetration testing, or other potentially harmful techniques:
  * Verify explicit authorization requirements are stated
  * Look for clear warnings about legal and ethical boundaries
  * Ensure guidance on authorized practice environments (labs, CTFs, permission-required systems)
  * Confirm distinction between studying techniques and attacking systems is made

**d. Clarity and Readability**
- Fix typos, grammatical errors, inconsistent terminology
- Standardize formatting (e.g., "90 min" not "90min", consistent date formats)
- Ensure all acronyms are defined on first use
- Verify diagrams/maps have clear legends explaining symbols, colors, numbers
- Check that code blocks are properly formatted and representative

**e. Practicality Assessment**
- Verify mentioned tools are installable/usable in standard learner environments
- Check time estimates are realistic for target audience
- Ensure exercises have clear step-by-step instructions
- Confirm referenced external resources are accessible

**f. Progression and Flow**
- Validate section builds logically on previous content
- Ensure no significant jumps in difficulty or assumed knowledge
- Verify advanced topics reference and build upon fundamentals
- Check for clear "next steps" or connection to subsequent sections

### 3. Cross-Section Consistency Check
- Verify terminology is used consistently throughout
- Ensure formatting standards apply uniformly (time units, date formats, code styling)
- Confirm progression makes sense when viewing the entire curriculum
- Check that safety/ethics reminders appear consistently where needed

### 4. Final Validation
- Run through a sample exercise or lab to verify instructions work
- Spot-check a few external links for accessibility
- Verify the content matches the stated target level (beginner/intermediate/advanced)

## Common Pitfalls to Avoid

- **Unclear Visual Explanations**
  Always explain what numbers, colors, and symbols represent in diagrams and flowcharts
  *Reason: Learners waste time deciphering unclear visuals instead of learning content*

- **Missing Authorization Context**
  When teaching offensive techniques (scanning, exploitation, etc.), always state that explicit permission is required before attempting anything
  *Reason: Prevents accidental legal violations and promotes ethical practice in security education*

- **Inconsistent Time Formatting**
  Mixing formats like "90min", "1.5h", "90 minutes" creates unnecessary cognitive load
  *Reason: Consistency reduces friction and improves professionalism*

- **Overlooked Knowledge Gaps**
  Assuming learners know something that wasn't taught in prerequisite sections
  *Reason: Causes frustration and hinders learning progression when learners hit unexpected barriers*

- **Unrealistic Time Estimates**
  Claiming complex topics (like buffer overflow exploitation or web app pentesting) can be mastered in implausibly short times
  *Reason: Sets wrong expectations leads to rushed, superficial understanding*

- **Broken or Outdated References**
  Linking to tools, tutorials, or platforms that no longer exist or have significantly changed
  *Reason: Frustrates learners and erodes trust in the material*

## Output Standards

After reviewing, the technical educational content should include:

1. **Clear, actionable learning objectives** for each section
2. **Explicit, accurate prerequisites** that match what's actually assumed
3. **Prominent safety/ethics notices** when offensive techniques are covered
4. **Standardized formatting** throughout (time units, dates, code, terminology)
5. **Logical progression** where each section builds on previous ones
6. **Practical, verifiable exercises** with clear instructions and expected outcomes
7. **Accessible resources** - all mentioned tools, platforms, and references are currently usable

## Quick Reference Checks

When reviewing, always ask:

- "Can a true beginner follow this from start to finish?"
- "Are authorization and ethics clearly addressed before any offensive techniques?"
- "Is every diagram/map immediately understandable with its explanation?"
- "Are time estimates realistic for the stated audience?"
- "Do prerequisites actually match what's needed to succeed in this section?"
- "Would following these instructions exactly work in a standard lab environment?"

## Maintenance

Technical content should be reviewed:
- Before initial publication
- After significant updates (>20% content change)
- Quarterly for external link validity
- Whenever learner feedback indicates confusion or difficulty
