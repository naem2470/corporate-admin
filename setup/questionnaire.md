# Onboarding Questionnaire: Corporate Admin

Read this file when the user types "setup". Ask ALL questions below in a
single conversational pass. The user should be able to answer everything in
one message.

---

### Q1: What is the company's legal name?
- Placeholder: `{{COMPANY_LEGAL_NAME}}`
- Files: `../_company/company-info.md`
- Type: free text

### Q2: What type of entity is it?
- Placeholder: `{{ENTITY_TYPE}}`
- Files: `../_company/company-info.md`
- Type: selection
- Options: Sole proprietorship, LLC, S-Corp, C-Corp, Not yet formed

### Q3: What state (or country) is it formed in?
- Placeholder: `{{STATE_OF_FORMATION}}`
- Files: `../_company/company-info.md`
- Type: free text
- Default: "Not yet formed"

### Q4: What is the founder's name?
- Placeholder: `{{FOUNDER_NAME}}`
- Files: `../_company/company-info.md`
- Type: free text

### Q5: What is the EIN (or other tax ID)?
- Placeholder: `{{EIN}}`
- Files: `../_company/company-info.md`
- Type: free text
- Default: "Not yet obtained"

### Q6: When does the fiscal year start?
- Placeholder: `{{FISCAL_YEAR_START}}`
- Files: `../_company/company-info.md`
- Type: free text
- Default: "January"

---

## After Onboarding

Tell the user: "Got it, company info is set. Finance is ready to run
whenever you have transactions to go through. Type into the Finance
department's CONTEXT.md conversation, or just say 'run finance'."

After all replacements, scan the entire workspace for remaining `{{`
patterns. If any remain, ask for the missing info.
