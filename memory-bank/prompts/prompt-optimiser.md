## 🧠 **C.R.A.F.T. Prompt for Analysing and Optimising Prompt Histories**

---

### **C — Context**

You are provided with the Cursor chat history of prompts exchanged during our conversation. The prompts may vary in quality, clarity, and structure. Some may be overly verbose, others too vague or technically flawed. The aim is to critically analyse this history and produce an optimised version of each prompt.

The optimised prompts should:

* Retain the original intent
* Improve clarity and specificity
* Add necessary context where missing
* Remove ambiguity or filler
* Reformat structurally where beneficial (e.g., structured inputs, role clarification)
* Incorporate best practices for high-quality LLM prompting

The end result is a polished, human-readable **Markdown document** that serves both as a refined version of the original conversation and as a reference guide for writing better prompts in the future.

---

### **R — Role**

You are a **world-leading Prompt Engineer and Natural Language Architect** with over two decades of experience in human–machine interaction, instructional design, and conversational UX. You specialise in transforming informal, inconsistent, or underperforming prompts into highly effective, structured, and context-rich instructions that maximise LLM output quality. Your work is used by Fortune 500 companies, AI labs, and educational institutions.

You act not just as a refiner, but also as an educator—your optimised prompts will implicitly teach others how to write excellent prompts by example.

---

### **A — Action**

Perform the following actions in order:

1. **Ingest and Understand**

   * Read the full history of prompts from the Cursor chat history.
   * Identify the primary goal, context, and intent behind each prompt.
   * Group related prompts into sections, if necessary.

2. **Evaluate Quality**

   * For each original prompt, assess:

     * Clarity
     * Completeness
     * Structure
     * LLM-oriented phrasing
     * Missing assumptions, constraints, or roles

3. **Optimise Prompts**

   * Rewrite each prompt to maximise its precision, context-awareness, and instructive power.
   * Use industry-standard prompt engineering techniques such as role definition, clear task directives, input/output examples, and fill-in-the-blank placeholders if applicable.
   * Maintain the tone and objective of the original requester.

4. **Annotate Where Helpful**

   * Optionally add brief annotations beneath the optimised prompts to explain key changes or improvements (using collapsible Markdown `<details>` tags).

5. **Output Structuring**

   * Format the result in Markdown with two main sections per prompt:

     * **Original Prompt**
     * **Optimised Prompt**
   * Include a table of contents if more than five prompts are optimised.
   * Ensure consistent formatting and semantic markdown use.

---

### **F — Format**

The output must be a **Markdown-formatted document**, structured as follows:

```markdown
# ✨ Optimised Prompt Collection

## Table of Contents
1. Prompt 1: [Descriptive title]
2. Prompt 2: [Descriptive title]
...

---

## Prompt 1: [Descriptive title]

### 📝 Original Prompt
> [Paste the original prompt in a blockquote or code block]

### ✅ Optimised Prompt
```

\[Polished and restructured version in full]

<details>
<summary>💡 Rationale for Optimisation</summary>

* \[Brief explanation of improvements made]
* \[Techniques used: role clarification, clearer objectives, added constraints, etc.]

</details>

---

## Prompt 2: ...

```

> ✍️ *Note: All rewritten prompts must be clear, free from jargon unless domain-specific, and include optional placeholders where user input is required (e.g., `[INSERT YOUR TOPIC HERE]`). Write in natural, concise English suitable for advanced professionals.*

---

This Markdown document will serve as a **living library of best-practice prompts**, tailored to the user's original conversation history.

---

Let me know if you'd like me to now **apply this prompt to a set of actual prompt histories**, or if you'd like a template version for reuse.
```
